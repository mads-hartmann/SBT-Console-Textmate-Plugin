About
=====

This is a Textmate plugin that adds a view at the bottom of a Textmate project window which allows you to type SBT commands like compile, test etc. 

To start an interactive sbt session simply type <code>sbt</code> or <code>sbt shell</code>. Once started you can exit it at any time by typing quit (as you would in the terminal). If you just want to run a single command you can just type <code>sbt compile</code>etc. 

**NOTICE**: Most of the code is heavily inspired by the project [Textmate Minimap](http://github.com/JulianEberius/Textmate-Minimap "Textmate Minimap") by [Julian Eberius ](http://github.com/JulianEberius "Julian Eberius ").

How to: Install
===============

Simply download the latest build from the Downloads page and add the SBT_PATH shell variable in Textmate. It has to point to a shell script that starts SBT without colors, here's an example:

<pre><code>java -Xmx1512M -XX:+CMSClassUnloadingEnabled -Dsbt.log.noformat=true  -XX:MaxPermSize=256m -jar `dirname $0`/sbt-launch-0.7.4.jar "$@"</code></pre>

My SBT path is set like this: 

<pre><code>SBT_PATH = /Users/Mads/dev/tools/sbt/sbtnocolors</code></pre>

How to: Use
===========

Simply open a Textmate project and press ctrl+shift+1 and it will toggle the terminal. Now you can type in any SBT command and see the input in the console-view. 

cmd+shift+1 will toggle focus between the document and the console.

To start an interactive sbt session simply type <code>sbt</code> or <code>sbt shell</code>. Once started you can exit it at any time by typing quit (as you would in the terminal). If you just want to run a single command you can just type <code>sbt compile</code>etc. 

The plugin adds a preference tab where you can change the colors used to display errors/warnings etc.

<a href="http://farm5.static.flickr.com/4074/4928878266_5f43a9dd7a_b.jpg" style="float:left"><img src="http://farm5.static.flickr.com/4074/4928878266_5f43a9dd7a_m.jpg" alt="Console"></a>

<a href="http://farm5.static.flickr.com/4140/4928284269_c77164c5b6_b.jpg" style="float:left">
<img src="http://farm5.static.flickr.com/4140/4928284269_c77164c5b6_m.jpg" alt="Preference Pance" /></a>

<a href="http://farm5.static.flickr.com/4116/4928295507_085e2d9b2f_b.jpg" style="float:left;">
  <img src="http://farm5.static.flickr.com/4116/4928295507_085e2d9b2f_m.jpg" alt="Console with errors" />
</a>