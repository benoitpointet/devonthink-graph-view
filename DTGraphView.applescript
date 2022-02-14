use AppleScript version "2.4" -- Yosemite (10.10) or later

use scripting additions
use framework "Foundation"
use script "RegexAndStuffLib" version "1.0.7"
use script "Dialog Toolkit Plus" version "1.1.2"

-- classes, constants, and enums used
property NSJSONSerialization : a reference to current application's NSJSONSerialization
property NSJSONWritingPrettyPrinted : a reference to 0
property maxDepth : a reference to 1
property idleTime : 5 -- in seconds
property DTGVversion : "v2021-06-23"

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
	set theColor to "#444"
	-- todo cleanup: clarify why i need the context here
	tell application id "DNtp"
		set theType to get type of theItem as string
		if theType is "group" then set theColor to "#1af"
		set theRefURL to reference URL of theItem
		set theID to (get uuid of theItem) as string
		set theKind to (get kind of theItem) as string
		set theName to (get name of theItem as string)
		set theLabel to my labelify(theName, 48)
		set newNode to {|id|:theID, |label|:theLabel, |name|:theName, |kind|:theKind, x:(random number from 0 to 1000), y:(random number from 0 to 1000), |color|:theColor, xdlink:theRefURL}
	end tell
	return newNode
end nodify

on edgify(idA, idB, theLabel, theType, theColor)
	tell application id "DNtp"
		set newEdge to {|id|:idA & "-" & idB & "-" & theLabel, |source|:idA, target:idB, |type|:theType, |color|:theColor}
	end tell
	return newEdge
end edgify

on graphItemsSet(theList, theSettings)
	tell application id "DNtp"
		set nodes to {}
		set nodeIDs to {}
		set edges to {}
		set edgeIDs to {}
		set theLinkPattern to "x-devonthink-item:\\/\\/........-....-....-....-............"
		set theUuidPattern to "........-....-....-....-............"
		
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
			set idA to (get uuid of theItem) as string
			
			if (parentChildEdges of theSettings) then
				-- graph parent-child edges
				repeat with childItem in children of theItem
					if nodeIDs contains ((uuid of childItem) as string) then
						set idB to (get uuid of childItem) as string
						set edge to my edgify(idA, idB, "contains", "arrow", "#aff")
						if edgeIDs does not contain (|id| of edge) then
							set end of edgeIDs to |id| of edge
							set end of edges to edge
						end if
					end if
				end repeat
			end if
			
			-- graph "x-devonthink-item" links in URL edges
			if (xdtURLEdges of theSettings) then
				set theURL to get URL of theItem
				set theMatch to regex search once theURL search pattern theLinkPattern
				if theMatch is not missing value then
					-- display alert (theMatch as string)
					set idB to regex search once theMatch search pattern theUuidPattern
					if nodeIDs contains idB then
						set edge to my edgify(idA, idB, "source-url", "arrow", "#cd2")
						if edgeIDs does not contain (|id| of edge) then
							set end of edgeIDs to |id| of edge
							set end of edges to edge
						end if
					end if
				end if
			end if
			
			-- graph "x-devonthink-item" in-text links from source as edge
			if (xdtInTextEdges of theSettings) then
				set theOutLinks to (get outgoing references of theItem)
				if theOutLinks is not {} then
					-- display alert (theMatches as string)
					repeat with theOutLink in theOutLinks
						set idB to (get uuid of theOutLink) as string
						if nodeIDs contains idB then
							set edge to my edgify(idA, idB, "x-link", "arrow", "#808")
							if edgeIDs does not contain (|id| of edge) then
								set end of edgeIDs to |id| of edge
								set end of edges to edge
							end if
						end if
					end repeat
				end if
			end if
			
			-- graph in-text wiki links from source as edge
			if (wikiLinksdEdges of theSettings) then
				set theOutLinks to (get outgoing Wiki references of theItem)
				if theOutLinks is not {} then
					-- display alert (theMatches as string)
					repeat with theOutLink in theOutLinks
						set idB to (get uuid of theOutLink) as string
						if nodeIDs contains idB then
							set edge to my edgify(idA, idB, "wiki-link", "arrow", "#f4d")
							if edgeIDs does not contain (|id| of edge) then
								set end of edgeIDs to |id| of edge
								set end of edges to edge
							end if
						end if
					end repeat
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
			set theMode to "Search"
			set theModeExtra to search query of theWindow
			if theSelection is {} then set theSelection to search results of theWindow
		else
			set theMode to "Group"
			set theModeExtra to name of current group
			if theSelection is {} then set theSelection to children of current group
			-- set end of theSelection to current group
		end if
		
		-- poll user for settings
		
		set accViewWidth to 400
		set theTop to 0
		set {theButtons, minWidth} to create buttons {"Cancel", "OK"} default button 1 given «class btns»:2
		if minWidth > accViewWidth then set accViewWidth to minWidth -- make sure buttons fit
		set {theRule, theTop} to create rule (theTop + 12) rule width accViewWidth
		set {XdtInTextCheckbox, theTop, newWidth} to create checkbox "Display x-devonthink-item links from content as purple edges." bottom (theTop + 8) max width accViewWidth / 2 - 8 with initial state
		set {WikiLinkCheckbox, theTop, newWidth} to create checkbox "Display wiki links from content as pink edges." bottom (theTop + 8) max width accViewWidth / 2 - 8 with initial state
		set {XdtURLCheckbox, theTop, newWidth} to create checkbox "Display x-devonthink-item links in URL as green edges." bottom (theTop + 8) max width accViewWidth / 2 - 8 with initial state
		set {parentChildCheckbox, theTop, newWidth} to create checkbox "Display parent-child relationships as cyan edges." bottom (theTop + 8) max width accViewWidth / 2 - 8 with initial state
		set {boldLabel, theTop} to create label "Generate a graph from the selected items" bottom theTop + 20 max width accViewWidth control size large size aligns center aligned with bold type
		set allControls to {XdtInTextCheckbox, WikiLinkCheckbox, XdtURLCheckbox, parentChildCheckbox, boldLabel}
		set {buttonName, controlsResults} to display enhanced window "DT GraphView - " & DTGVversion acc view width accViewWidth acc view height theTop acc view controls allControls buttons theButtons with align cancel button
		
		set theSettings to {xdtInTextEdges:(get item 1 of controlsResults), wikiLinksdEdges:(get item 2 of controlsResults), xdtURLEdges:(get item 3 of controlsResults), parentChildEdges:(get item 4 of controlsResults)}
		
		-- abort if cancel
		if buttonName is equal to "Cancel" then
			return
		end if
		
		-- abort if no type of edges selected
		if not ((get xdtInTextEdges of theSettings) or (get xdtInTextEdges of theSettings) or (get xdtURLEdges of theSettings) or (get parentChildEdges of theSettings)) then
			return
		end if
		
		-- generate graph
		set {nodes, edges} to my graphItemsSet(theSelection, theSettings)
		-- display alert (length of nodes as string) & " nodes, " & (length of edges as string) & " edges"
		show progress indicator "Graph View : preparing view ..."
		set theJSONData to my toJSON({nodes:nodes, edges:edges})
		-- display alert (theJSONData)
		
		-- generate HTML file
		set posixPath to POSIX path of ((path to me as text) & "::") -- html parts need to stay next to script file
		set htmlPart1 to read (posixPath & "part1.html")
		set htmlPart2 to read (posixPath & "part2.html")
		set theJS to "graphThis(" & (theJSONData as text) & ");"
		set theHTML to htmlPart1 & theJS & htmlPart2
		set exportName to theMode & ": '" & theModeExtra & "' - network view (" & (length of nodes as string) & "n, " & (length of edges as string) & "e" & ")"
		set exportLocation to root of inbox
		set theRecord to create record with {name:exportName, type:html, content:theHTML, locking:true} in exportLocation
		open window for record theRecord
		hide progress indicator
	end tell
end run
