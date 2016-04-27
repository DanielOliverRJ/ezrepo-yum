EZREPO-YUM
==========

A set of simple scripts to download a copy of yum repositories.


* ezrepo-yum.sh    - mirror a yum repo locally
* ezmirrors-yum.sh - cgi script to point clients to the local mirrors


Usage: ezrepo-yum
-----------------

Cron Example:
<pre>
0  1 * * * /usr/local/bin/ezrepo-yum.sh /etc/ezrepo/centos.repo
0  2 * * * /usr/local/bin/ezrepo-yum.sh /etc/ezrepo/epel.repo
</pre>
