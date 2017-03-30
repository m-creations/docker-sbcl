docker-sbcl
===========

An image based on [OpenWrt](http://openwrt.org) x86_64 which runs
[SBCL (Steel Bank Common Lisp)](http://sbcl.org).

[Quicklisp](https://quicklisp.org) is installed in /opt/quicklisp.

Sources can be mounted into the image into /common-lisp.

Compiled files are cached in the directory /cache.

How to use
----------

We assume that you keep your own source files in `~/common-lisp` and
the cache location is the default one `~/.cache`. Then you can use the
following command

```
docker run -it -v ~/common-lisp:/common-lisp -v ~/.cache:/cache mcreations/sbcl
```

It is possible to override the quicklisp installation inside the
container with the one which you have (default location `~/quicklisp`):

```
docker run -it -v ~/quicklisp:/opt/quicklisp -v ~/common-lisp:/common-lisp -v ~/.cache:/cache mcreations/sbcl
```

Github Repo
-----------

https://github.com/m-creations/docker-sbcl

