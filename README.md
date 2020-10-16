# devonthink-graph-view

This script generates a graph visualization of a set of  [Devonthink](https://www.devontechnologies.com/apps/devonthink)  (DT) records & groups.

## Origins

It takes its origin in a [forum discussion](https://discourse.devontechnologies.com/t/node-graph-for-document-links/) about the value of graph visualization for Devonthink.

## Content

The scripts contains different files:
* `DTGraphView.applescript` : the script that parses the items set and generates graph data.
* `part1.html` & `part2.html` : the web page (split in two parts) in which the data is injected.
* `/sigma/` the [sigma.js](https://github.com/jacomyal/sigma.js) library used to draw the interactive graph (not loaded actively though), just here for customization means.

## Installation

* Git-clone it, or [download it as a zip archive](https://github.com/benoitpointet/devonthink-graph-view/archive/main.zip).
* This script requires the [RegexAndStuffLib (min v1.0.6)](https://latenightsw.com/support/freeware/) script to run.

## Usage
1. **Select items (either from a search or within the hierarchy) then launch the applescript.** If you launch without selecting, the script will take all search results if in search mode, else the direct children of the current group.
2. A progress bar appears showing you progress info.
3. The script generates a graph of the nodes:
	* Every items is represented as a node of the graph, groups are blue.
	* **Several relationships are represented as edges**:
		* **"A contains B"** relationships (like in "group A contains record/group B")
		* "**x-devonthink-item" links in the record URL** (often used to point to the source of a record).
		* **Wiki links in Markdown files**.
4. The script then embeds the graph data into a HTML doc which by default saves in the global Inbox and open in a separate window.
5. At first the graph might looks messy and frozen for a few (milli-)seconds: the force-directed layout algorithm has kicked in. Then the graph moves and stabilizes. The speed of this depends on graph complexity (see performance below).
6. You may interact with the graph in the following ways:
	* Once the graph layout is good enough for you, you may click on the "freeze" link to stop the algorithm and thus freeze the display.
	* You may zoom in/out and pan in the graph, like on an interactive map.
	* Double-click on a node to open the item in DT.

## Performance
* It performs well under ~200 items. Over that, it gets sluggish (depends on your machine, of course).

## Feedbacks & discussion
For questions, remarks and help please ask on this thread [https://discourse.devontechnologies.com/t/graph-view-a-network-visualization-script-for-dt/58782](https://discourse.devontechnologies.com/t/graph-view-a-network-visualization-script-for-dt/58782).