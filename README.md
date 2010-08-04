Installation
============

Simply download the latest build from the Downloads page and add the SBT_PATH shell variable in Textmate. It has to point to a shell script that starts SBT without colors, here's an example:

<pre><code>java -Xmx1512M -XX:+CMSClassUnloadingEnabled -Dsbt.log.noformat=true  -XX:MaxPermSize=256m -jar `dirname $0`/sbt-launch-0.7.4.jar "$@"</code></pre>

My SBT path is set like this: 

<pre><code>SBT_PATH = /Users/Mads/dev/tools/sbt/sbtnocolors</code></pre>