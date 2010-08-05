Usage
=====

Simply open a Textmate proejct and press cmd+shift+$ and it will toggle the terminal. Now you can type in any SBT command and see the input in the console-view. 

cmd+$ will toggle focus between the document and the console.

Todo
====

- Convert errors to links so you can jump to errors by clicking on the error lines.
- Make short-keys for next error / previous error 
- Implement "history" so you can pre key-up/key-down to cycle through previous commands

Installation
============

Simply download the latest build from the Downloads page and add the SBT_PATH shell variable in Textmate. It has to point to a shell script that starts SBT without colors, here's an example:

<pre><code>java -Xmx1512M -XX:+CMSClassUnloadingEnabled -Dsbt.log.noformat=true  -XX:MaxPermSize=256m -jar `dirname $0`/sbt-launch-0.7.4.jar "$@"</code></pre>

My SBT path is set like this: 

<pre><code>SBT_PATH = /Users/Mads/dev/tools/sbt/sbtnocolors</code></pre>