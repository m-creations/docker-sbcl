docker-sbcl
===========

An image based on Debian + [MetaCall](https://metacall.io/) x86_64
runtime Docker image which runs [SBCL (Steel Bank Common
Lisp)](http://sbcl.org).

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

The userid of the sbcl process can be specified explicitly (default is
1000), groupid will be 0 (= root).

How to use
----------

To have a consistent situation inside the container and on the host,
on our development machines, we install Quicklisp in `/opt/quicklisp`
(and set the env var `QUICKLISP_HOME`). We keep our source files in
`/common-lisp` (with a symbolic link in `~/common-lisp` and the cache
location is `/cache` (with a link to `~/.cache`). Then you can use the
following command

```
docker run -it -v /common-lisp:/common-lisp -v /cache:/cache mcreations/sbcl
```

But it is perfectly possible to mount the usual locations of those
dirs into the container image:

```
docker run -it -v $HOME/common-lisp:/common-lisp -v $HOME/.cache:/cache mcreations/sbcl
```


It is of course possible to override the quicklisp installation inside
the container with the one which you have (e.g. from location
`~/quicklisp`):

```
docker run -it -v ~/quicklisp:/opt/quicklisp -v ~/common-lisp:/common-lisp -v ~/.cache:/cache mcreations/sbcl
```

User ID and Group ID
--------------------

The sbcl process inside the container runs with UID 1000 (user name
'lisp') and GID 0.  If you specify host volumes to be mounted inside
the container, then you should set the env var `RUN_AS` to your own
UID. The files which are created by sbcl will then have the correct
user and group:

```
docker run -it -e RUN_AS=`id -u` -v ~/common-lisp:/common-lisp -v ~/.cache:/cache mcreations/sbcl
```

These directories have gid 0 and are group-writable inside the container:
    
- /opt/quicklisp
- /common-lisp
- /cache

so, when you mount host volumes, make sure they are either writable by
the UID in `RUN_AS` or by group root.

Environment variables
---------------------

- `RUN_AS`: see section 'User ID and Group ID'

- `QL_VERBOSE`: if set, Quicklisp loading will be verbose (compile
  messages and warnings instead of printing dots to signify progress)

Readline support
----------------

When running the image interactively, you can use [GNU readline](https://directory.fsf.org/wiki/Readline)
history and editing capabilities.

Github Repo
-----------

https://github.com/m-creations/docker-sbcl

