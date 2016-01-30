# php7-wp-build-docker

## Goal:
1.  Build a .deb package (primarily focusing on Ubuntu LTS for now) of php 7 latest stable release, optimized for running wordpress.
2.  Automate that process via docker so that we can always snag the lastest stable source to build the packages.

## Inspiration:
1.  This [thread](http://www.serverphorums.com/read.php?7,1215001) about how it could be done and the potential performance improvements to be had.
2.  I like the way this guy at yammer used a Makefile to orchestrate Docker so I basically stole [it](https://github.com/yammer/mcrouter-build-docker)

## How to use:
```
git clone https://github.com/kevinquinnyo/php7-wp-build-docker.git
cd php7-wp-build-docker
make
```
You need to have docker installed.
That will build a .deb in `./14.04/` for the latest php, optimized for wordpress.  It doesn't have any post-install scriptlets or additional fanciness. It doesn't even contain a php.ini or init script -- that needs improvement.


## Contributing:
I welcome it.  Just fork, and make a PR.  It will probably be accepted.

