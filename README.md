docker-sbcl
===========

An image based on [OpenWrt](http://openwrt.org) x86_64 which runs
[SBCL (Steel Bank Common Lisp)](http://sbcl.org).

[Quicklisp](https://quicklisp.org) is installed in /opt/quicklisp. We provide
different versions (tags) for different distributions of Quicklisp:

- version `x.y.z` contains the corresponding sbcl version (built with
  build option 'fancy'), and the 'current' Quicklisp version (current
  at container build time) with no systems pre-installed

- version `x.y.z-YYYY-MM-DD` contains sbcl `x.y.z` and Quicklisp
  `YYYY-MM-DD`, where all package archives are downloaded into the
  image

The latter image is large (400-500 MB) but contains all of Quicklisp,
so no Internet connectivity is needed for `quickload`ing systems.

Sources can be mounted into the image into /common-lisp.

Compiled files are cached in the directory /cache.

The userid and groupid of the sbcl process can be specified explicitly.

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

User ID and Group ID
--------------------

The sbcl process inside the container runs with UID 1000 and GID 1000.
If you specify host volumes to be mounted inside the container, then
you should set the env var `RUN_AS` to your own UID and GID. The files
which are created by sbcl will then have the correct user and group:

```
docker run -it -e RUN_AS=`id -u`:`id -g` -v ~/quicklisp:/opt/quicklisp -v ~/common-lisp:/common-lisp -v ~/.cache:/cache mcreations/sbcl
```

During startup, the startup script modifies owner and group of the directories
    
- /opt/quicklisp
- /cache

to match the value of `RUN_AS`.

Note that this will take quite some time, so you should always run the
image with the same `RUN_AS` value (cf. above).

Readline support
----------------

When running the image interactively, you can use [GNU readline](https://directory.fsf.org/wiki/Readline)
history and editing capabilities.

Github Repo
-----------

https://github.com/m-creations/docker-sbcl

