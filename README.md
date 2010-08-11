What is it
==========

This is a Textmate plugin that adds a view at the bottom of a Textmate project window which allows you to type SBT commands like compile, test etc. It's equal to typing "> sbt compile" etc. in a terminal. This means that you can't use jetty-run because it starts sbt, runs the command and shuts down sbt. It doesn't start an interactive session. I will try to fix this as starting/stopping sbt adds useless overhead. You can still use ~compile though.

Usage
=====

Simply open a Textmate project and press ctrl+shift+1 and it will toggle the terminal. Now you can type in any SBT command and see the input in the console-view. 

cmd+shift+1 will toggle focus between the document and the console.

Features
========

- Any errors in the output links to the correct line the the appropriate file.

Todo
====

- Make short-keys for next error / previous error 
- Implement "history" so you can pre key-up/key-down to cycle through previous commands

Installation
============

Simply download the latest build from the Downloads page and add the SBT_PATH shell variable in Textmate. It has to point to a shell script that starts SBT without colors, here's an example:

<pre><code>java -Xmx1512M -XX:+CMSClassUnloadingEnabled -Dsbt.log.noformat=true  -XX:MaxPermSize=256m -jar `dirname $0`/sbt-launch-0.7.4.jar "$@"</code></pre>

My SBT path is set like this: 

<pre><code>SBT_PATH = /Users/Mads/dev/tools/sbt/sbtnocolors</code></pre>