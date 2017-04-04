## -*- docker-image-name: "mcreations/sbcl" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 1.3.16-3-g318f311~yakkety+5

ENV DOWNLOAD_URL https://launchpad.net/~darabi/+archive/ubuntu/lisp/+files

ENV DOWNLOAD_PACKAGE sbcl_${SBCL_VERSION}_amd64.deb

ENV SHA256_SUM 95654ba25040fce3e01cad56c01024122c0b245097eff4d3be5d0c69c14656bd

ENV QUICKLISP_HOME /opt/quicklisp

ENV XDG_CACHE_HOME /cache

RUN opkg update &&\
    opkg install \
         ar \
         coreutils-sha256sum \
         gcc \
         make \
         tar \
         xz \
         zoneinfo-core &&\
    rm /etc/localtime &&\
    ln -s /usr/share/zoneinfo/UTC /etc/localtime &&\
    cd /tmp &&\
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
    echo | sbcl --load /tmp/quicklisp.lisp --eval '(quicklisp-quickstart:install :path "/opt/quicklisp")' --eval '(quicklisp:add-to-init-file)' --eval '(sb-ext:quit)'

CMD ["sbcl"]
