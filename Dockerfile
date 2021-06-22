## -*- docker-image-name: "mcreations/sbcl" -*-

FROM registry.gitlab.com/darabi/metacall/metacall-runtime:latest
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 2:2.1.1.mc2-4~bionic+1

ENV QUICKLISP_VERSION 2021-04-11

ENV MCREATIONS_DIST_VERSION 2021-05-22-1215

ENV QUICKLISP_HOME /opt/quicklisp

# if changing this, check the whole config, as '/common-lisp' is
# hard-coded below and in /usr/bin/start-sbcl
ENV CL_SOURCE_REGISTRY '(:source-registry (:tree "/common-lisp") :inherit-configuration)'

ENV XDG_CACHE_HOME /cache

ENV CC gcc

ENV DEBIAN_FRONTEND noninteractive

# userid to run sbcl with (group id will be 0 which corresponds to the setting on OpenShift)
ENV RUN_AS 1000

# contains the start-sbcl script and a patch for quicklisp-client's
# mtime handling when unpacking tar files
ADD image/root/tmp/* /tmp/
ADD image/root/usr/bin/* /usr/bin/

RUN apt-get update && apt-get install -y --no-install-recommends gnupg ca-certificates &&\
    echo "deb http://ppa.launchpad.net/darabi/lisp/ubuntu bionic main" > /etc/apt/sources.list.d/darabi-lisp.list &&\
    apt-key add /tmp/launchpad-ppa-gpg.key &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends sbcl=$SBCL_VERSION \
            pkg-config \
            g++ \
            gnupg \
            gosu \
            libffi6 libffi-dev \
            libfixposix3 libfixposix-dev \
            libgvc6 libgraphviz-dev \
            libuv1 libuv1-dev \
            patch \
            rlwrap \
            wget \
            zlib1g zlib1g-dev &&\
    cd ~ &&\
    printf "\n\nFinished installing SBCL. Now it's time for Quicklisp.\n\n" &&\
    wget -O /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp &&\
    mkdir -p /opt &&\
    mkdir -p /common-lisp &&\
    mkdir -p /usr/share/common-lisp  &&\
    mkdir -p $XDG_CACHE_HOME &&\
    echo | sbcl --load /tmp/quicklisp.lisp --eval '(quicklisp-quickstart:install :path "/opt/quicklisp")' --eval '(quicklisp:add-to-init-file)' --eval '(sb-ext:quit)' &&\
    echo | sbcl --load /opt/quicklisp/setup.lisp --eval "(ql-dist:install-dist \"http://beta.quicklisp.org/dist/quicklisp/$QUICKLISP_VERSION/distinfo.txt\" :replace t)" \
         --eval "(mapcar #'ql-dist:ensure-local-archive-file (mapcar #'ql-dist:release (ql-dist:provided-systems (ql-dist:find-dist \"quicklisp\"))))" &&\
    echo | sbcl --load /opt/quicklisp/setup.lisp --eval "(ql-dist:install-dist \"http://ql.m-creations.net/m-creations/$MCREATIONS_DIST_VERSION/distinfo.txt\" :replace t)" \
         --eval "(mapcar #'ql-dist:ensure-local-archive-file (mapcar #'ql-dist:release (ql-dist:provided-systems (ql-dist:find-dist \"m-creations\"))))" &&\
    echo | sbcl --eval '(ql:quickload :swank)' &&\
    cd /opt/quicklisp &&\
    patch -p 1 < /tmp/001-minitar-set-file-mtime.patch &&\
    chgrp -R 0 ${QUICKLISP_HOME} &&\
    chgrp -R 0 ${XDG_CACHE_HOME} &&\
    chmod -R g=u /etc/passwd ${QUICKLISP_HOME} ${XDG_CACHE_HOME} &&\
    mv /usr/bin/sbcl /usr/bin/sbcl-binary &&\
    mv /usr/bin/start-sbcl /usr/bin/sbcl &&\
    printf "\n\nModifying MetaCall global configuration\n\n" &&\
    echo '{ "log_level": "Debug" }' > /usr/local/share/metacall/configurations/global.json


ENTRYPOINT ["sbcl"]
