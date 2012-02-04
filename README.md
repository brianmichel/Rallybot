Rally Hubot Script
===========================
This script was designed to get useful information from Rally at a moments notice. When someone says, "Hey what's going on with DE192810181081?" Instead of lying, because your mind doesn't work in defect numbers, you can use this to jog you brain as to what is __ACTUALLY__ happening with that defect or task.

It helps you, it's helps them, it makes people happy, and saves kitties.

Requirements
------------
 1. Hubot up and running (I think that's it.)
 2. Lynx should be installed and PATH accessible for pretty printed descriptions (brew install lynx)

Setup
-----
 Drop this script in your Hubot's scripts directory and reload the bot. 

Usage
-----

	<Your Hubot name> rally me DE1919810
or

	<Your Hubot name> rally me TA91881801

or

	<Your Hubot name> rally me US9181801

 So right now it only does the basic elements (defects, tasks, stories), but I'll try to extend it and get some interesting things going, like open bug counts per person per project, etc. Maybe even some sweet ass graphs, who knows. 

Additions
---------
 I'm looking to expand this into something more full featured, however, I'll be taking feature requests so that I can actually fulfill the needs of others. Please feel free to create an issue against to for your feature request. You can also find me on twitter [@brianmichel](http://www.twitter.com/#!/brianmichel).