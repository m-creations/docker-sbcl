## -*- docker-image-name: "mcreations/sbcl" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 1.4.1-101-ga860f4780~zesty+2

ENV DOWNLOAD_URL https://launchpad.net/~darabi/+archive/ubuntu/lisp/+files

ENV DOWNLOAD_PACKAGE sbcl_${SBCL_VERSION}_amd64.deb

ENV SHA256_SUM 1d5cde1fe824f2ff9560600bfb657fec7b864a5c362d3a3f5003111425818f26

ENV QUICKLISP_HOME /opt/quicklisp

ENV XDG_CACHE_HOME /cache

ENV GOSU_VERSION 1.10

# userid:groupid to run sbcl with
ENV RUN_AS 1000:1000

RUN opkg update &&\
    opkg install --force-overwrite \
         ar \
         coreutils-id \
         coreutils-sha256sum \
         coreutils-stat \
         gcc \
         graphviz \
         libffi \
         libfixposix libfixposix-dev \
         libuv libuv-dev \
         make \
         rlwrap \
         shadow-groupadd \
         shadow-su \
         shadow-useradd \
         tar \
         xz \
         zoneinfo-core &&\
    rm /etc/localtime &&\
    ln -s /usr/share/zoneinfo/UTC /etc/localtime &&\
    mkdir /home &&\
    cd /tmp &&\
    wget -O gosu --progress=dot:giga "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" &&\
    chmod a+x gosu &&\
    mv gosu /usr/bin &&\
    wget --progress=dot:giga $DOWNLOAD_URL/$DOWNLOAD_PACKAGE &&\
    echo "$SHA256_SUM $DOWNLOAD_PACKAGE" | sha256sum -c &&\
    mkdir sbcl-unpack && cd sbcl-unpack &&\
    ar x ../$DOWNLOAD_PACKAGE &&\
    tar xfvJ /tmp/sbcl-unpack/data.tar.xz -C / &&\
    rm -rf /usr/share/{man,doc,lintian,binfmts} &&\
    rm -rf /tmp/sbcl* &&\
    rm /tmp/opkg-lists/* &&\
    cd ~ &&\
    echo "Finished installing SBCL. Now it's time for Quicklisp." &&\
    wget -O /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp &&\
    mkdir /opt &&\
    mkdir -p /common-lisp &&\
    mkdir -p /usr/share/common-lisp  &&\
    mkdir -p $XDG_CACHE_HOME &&\
    ln -s /common-lisp /usr/share/common-lisp/source &&\
    echo | sbcl --load /tmp/quicklisp.lisp --eval '(quicklisp-quickstart:install :path "/opt/quicklisp")' --eval '(quicklisp:add-to-init-file)' --eval '(sb-ext:quit)' &&\
    mv /usr/bin/sbcl /usr/bin/sbcl-binary

ADD image/root/start-sbcl /usr/bin/sbcl

ENTRYPOINT ["sbcl"]
