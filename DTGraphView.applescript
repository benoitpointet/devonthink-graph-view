use AppleScript version "2.4" -- Yosemite (10.10) or later
use script "RegexAndStuffLib" version "1.0.6"
use scripting additions
use framework "Foundation"

-- classes, constants, and enums used
property NSJSONSerialization : a reference to current application's NSJSONSerialization
property NSJSONWritingPrettyPrinted : a reference to 0
property maxDepth : a reference to 1
property idleTime : 5 -- in seconds

-- showJSON :: a -> String
-- from https://forum.latenightsw.com/t/writing-json-data-with-nsjsonserialization/1130
on toJSON(x)
	set c to class of x
	if (c is list) or (c as string is "record") then -- ugly to pass through string comp, but when ca is DT, test on class does not work
		set ca to current application
		set {json, e} to ca's NSJSONSerialization's dataWithJSONObject:x options:NSJSONWritingPrettyPrinted |error|:(reference)
		if json is missing value then
			e's localizedDescription() as text
		else
			(ca's NSString's alloc()'s initWithData:json encoding:(ca's NSUTF8StringEncoding)) as text
		end if
		--	else if c is date then
		--		"\"" & ((x - (time to GMT)) as "class isot" as string) & ".000Z" & "\""
	else if c is text then
		"\"" & x & "\""
	else if (c is integer or c is real) then
		x as text
	else if c is class then
		"null"
	else
		try
			x as text
		on error
			("'" & c as text) & "'"
		end try
	end if
end toJSON

on labelify(theName, max)
	if length of theName is less than max then
		return theName
	else
		return text 1 thru max of theName
	end if
end labelify

on nodify(theItem)
	set theColor to "#333"
	-- todo cleanup: clarify why i need the context here
	tell application id "DNtp"
		set theType to get type of theItem as string
		if theType is "group" then set theColor to "#1af"
		set theRefURL to reference URL of theItem
		set theID to (get uuid of theItem) as string
		set theLabel to my labelify(get name of theItem as string, 128)
		set newNode to {|id|:theID, |label|:theLabel, x:(random number from 0 to 1000), y:(random number from 0 to 1000), |color|:theColor, xdlink:theRefURL}
	end tell
	return newNode
end nodify

on edgify(idA, idB, theLabel)
	set newEdge to {|id|:idA & "-" & idB, source:idA, target:idB, label:theLabel}
	return newEdge
end edgify

on graphItemsSet(theList)
	tell application id "DNtp"
		set nodes to {}
		set nodeIDs to {}
		set edges to {}
		set edgeIDs to {}
		
		-- first pass to graph nodes
		show progress indicator "Graph View : processing " & (length of theList) & " items" steps 2 * (length of theList) + 1
		repeat with theItem in theList
			step progress indicator
			if nodeIDs does not contain (uuid of theItem as string) then
				set node to my nodify(theItem)
				set end of nodes to node
				set end of nodeIDs to |id| of node
			end if
		end repeat
		
		-- second pass to graph edges
		show progress indicator "Graph View : processing links ..."
		repeat with theItem in theList
			step progress indicator
			
			-- graph parent-child edges
			set idA to (get uuid of theItem) as string
			repeat with childItem in children of theItem
				if nodeIDs contains ((uuid of childItem) as string) then
					set idB to (get uuid of childItem) as string
					set edge to my edgify(idA, idB, "contains")
					if edgeIDs does not contain (|id| of edge) then
						set end of edgeIDs to |id| of edge
						set end of edges to edge
					end if
				end if
			end repeat
			
			-- graph "x-devonthink-item" links in URL edges
			set theURL to get URL of theItem
			set theMatch to regex search once theURL search pattern "x-devonthink-item:\\/\\/"
			if theMatch is not missing value then
				set idB to regex search once theURL search pattern "........-....-....-....-............"
				if nodeIDs contains idB then
					set edge to my edgify(idA, idB, "source (url)")
					if edgeIDs does not contain (|id| of edge) then
						set end of edgeIDs to |id| of edge
						set end of edges to edge
					end if
				end if
			end if
			
		end repeat
	end tell
	return {nodes, edges}
end graphItemsSet

on run
	tell application id "DNtp"
		
		-- prepare graph data for items set in frontmost window
		set theWindow to viewer window 1
		
		set theSelection to selection
		
		-- if a search or not
		if search results of theWindow is not {} then
			if theSelection is {} then set theSelection to search results of theWindow
		else
			if theSelection is {} then set theSelection to children of current group
			set end of theSelection to current group
		end if
		
		-- generate graph
		set {nodes, edges} to my graphItemsSet(theSelection)
		-- display alert (length of nodes as string) & " nodes, " & (length of edges as string) & " edges"
		show progress indicator "Graph View : preparing view ..."
		set theJSONData to my toJSON({nodes:nodes, edges:edges})
		-- display alert (theJSONData)
		
		-- open the html and inject graph data
		set posixPath to POSIX path of ((path to me as text) & "::")
		set graphWindowPath to "file://" & posixPath & "index.html"
		set graphWindow to open tab for URL graphWindowPath
		
		set theJS to "graphThis(" & (theJSONData as text) & ");"
		set theResult to do JavaScript theJS in graphWindow
		
		hide progress indicator
	end tell
end run
