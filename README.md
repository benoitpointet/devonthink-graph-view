# devonthink-graph-view

This script generates a graph visualization of part of a [Devonthink](https://www.devontechnologies.com/apps/devonthink)  (DT) database.

## Origins

It takes its origin in a [forum discussion](https://discourse.devontechnologies.com/t/node-graph-for-document-links/) about the value of graph visualization for Devonthink.

## Structure

It contains 3 parts:
* `DTGraphView.applescript` : the script that parses the items set and generates graph data.
* `index.html` : the web page in which the data is injected.
* `/sigma/` the [sigma.js](https://github.com/jacomyal/sigma.js) library used to draw the interactive graph.

## Installation

Git-clone it, or [download it as a zip archive](https://github.com/benoitpointet/devonthink-graph-view/archive/main.zip).

## Usage
1. **Select several items then launch the applescript.** If you launch without selecting, the script will take all search results (if in search mode) or the direct children of the current group.
2. A progress bar appears showing you progress info.
3. The script opens the `index.html` file and populates it with the graph data. 
	* Every items is a node, groups are blue.
	* Edges represente parent-child relationships. 
4. You may zoom in/out and pan in the graph.
5. Double-click on a node to open the item in DT.

## Performance
It works well under 200 items. Over that, it's robust but sluggish: both generating the graph and letting the force-directed layout happen on the web page will take many seconds/minutes.

## Feedbacks & discussion
Welcome on this thread [https://discourse.devontechnologies.com/t/graph-view-a-network-visualization-script-for-dt/58782](https://discourse.devontechnologies.com/t/graph-view-a-network-visualization-script-for-dt/58782).