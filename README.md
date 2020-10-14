# devonthink-graph-view

This script generates a graph visualization of part of a [Devonthink](https://www.devontechnologies.com/apps/devonthink)  (DT) database.

## Origins

It takes its origin in a [forum discussion](https://discourse.devontechnologies.com/t/node-graph-for-document-links/) about the value of graph visualization for Devonthink.

## Structure

The scripts contains different parts:
* `DTGraphView.applescript` : the script that parses the items set and generates graph data.
* `part1.html` & `part2.html` : the web page in which the data is injected, split in two parts enclosing the inject data.
* `/sigma/` the [sigma.js](https://github.com/jacomyal/sigma.js) library used to draw the interactive graph (not loaded actively though).

## Installation

* This script needs the [RegexAndStuffLib (min v1.0.6)](https://latenightsw.com/support/freeware/) script.
* Git-clone it, or [download it as a zip archive](https://github.com/benoitpointet/devonthink-graph-view/archive/main.zip).

## Usage
1. **Select several items then launch the applescript.** If you launch without selecting, the script will take all search results (if in search mode) or the direct children of the current group.
2. A progress bar appears showing you progress info.
3. After having generated nodes for the set of items, the script generates edges for .
	* Every items is represented as a node of the graph, groups are blue.
	* Edges represent
		* "A contains B" relationships (like in "a group contains a record")
		* "x-devonthink-item" links in the URL property of records (often used to point to the source of a doc.
4. The script then embeds the graph data into a HTML doc which it by default will save in the global Inbox and open in a separate window.
	5. At first the graph looks messy and frozen for a few (milli-)seconds: the force-directed layout algorithm has kicked in. Then the graph moves and stabilizes. The speed of this depends on graph complexity (see performance below).
6. Once the graph layout is good enough for you, you may click on the "freeze" link to stop the algorithm.
5. You may zoom in/out and pan in the graph.
6. Double-click on a node to open the item in DT.

## Performance
* It performs well under 200 items. Over that, it gets sluggish (depends on your machine, of course).

## Feedbacks & discussion
Welcome on this thread [https://discourse.devontechnologies.com/t/graph-view-a-network-visualization-script-for-dt/58782](https://discourse.devontechnologies.com/t/graph-view-a-network-visualization-script-for-dt/58782).