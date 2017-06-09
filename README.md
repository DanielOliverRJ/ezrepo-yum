EZREPO-YUM
==========

A set of simple scripts to download a copy of yum repositories and advertise multiple internal yum mirrors.

The `ezrepo-yum.sh` was largely inspired by this gist: https://gist.github.com/brianredbeard/7034245 . Thanks RedBeard!

* `ezrepo-yum.sh` - mirror a yum repo locally
* `/cgi-bin/yum-mirrorlist.cgi` - cgi script to point clients to the local mirrors

ezrepo-yum
----------

### Usage (without container):

Cron Example:
<pre>
0  1 * * * /usr/local/bin/ezrepo-yum.sh /etc/ezrepo/centos.repo
0  2 * * * /usr/local/bin/ezrepo-yum.sh /etc/ezrepo/epel.repo
</pre>

### Usage (container):

#### BUILD:

<code>docker build -t ezrepo-plugin-yum-el7 .</code>

#### RUN:

You can do a manual test of the container on your workstation.  It will download the rpms into the download-test directory.

```bash
docker run --rm\
  -v ${PWD}/download-test:/var/www/repos/latest\
  -v ${PWD}/config-examples/:/etc/ezrepo:ro\
  ezrepo-plugin-yum-el7 /etc/ezrepo/centos-7.repo
```

/cgi-bin/yum-mirrorlist.cgi
---------------------------

### Usage:

Run it as a cgi script under apache (or other web server). A sample url would look like:

http://repo.local/mirrorlist?repo=epel-debug&arch=x86_64&product=epel&snap=20161103

Currently it supports the following standard 'mirrorlist' parameters:

| Param | Values                 |
|-------|------------------------|
| repo  | name of the repository |
| arch  | `x86_64`,`i386`,etc.   |

And the following custom parameters:

| Param   | Values                                  |
|---------|-----------------------------------------|
| product | the product the repository is a part of |
| snap    | `latest`, or YYYYMMDD like `20160128`   |

See https://github.com/ezrepo/ezrepo-base for more about snapshotting.

#### Testing

You can give it a quick test from the command line by uncommenting line 4, to use the example list of mirrors, and passing a test `QUERY_STRING`:

```bash
QUERY_STRING='repo=epel-debug&arch=x86_64&product=epel&snap=20161103' ./yum-mirrorlist.cgi
```

Should output:
```
Content-type: text/plain

http://localhost/archive/20161103/yum/epel/x86_64/epel-debug/
http://192.168.0.1:8080/archive/20161103/yum/epel/x86_64/epel-debug/
http://192.168.0.2/archive/20161103/yum/epel/x86_64/epel-debug/
http://mirror.local.localnet/archive/20161103/yum/epel/x86_64/epel-debug/
```
