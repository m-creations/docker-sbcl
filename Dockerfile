## -*- docker-image-name: "mcreations/sbcl" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 1.4.1-1

ENV DOWNLOAD_URL http://ftp.de.debian.org/debian/pool/main/s/sbcl

ENV DOWNLOAD_PACKAGE sbcl_${SBCL_VERSION}_amd64.deb

ENV SHA256_SUM f4a53f3f6742857ffc6855185d3985c8ca3dc94ec14964d749c7f12cb76611ce

ENV QUICKLISP_HOME /opt/quicklisp

ENV QUICKLISP_VERSION 2017-10-23

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
    echo | sbcl --load /opt/quicklisp/setup.lisp --eval "(ql-dist:install-dist \"http://beta.quicklisp.org/dist/quicklisp/$QUICKLISP_VERSION/distinfo.txt\" :replace t)" \
         --eval "(mapcar #'ql-dist:ensure-local-archive-file (mapcar #'ql-dist:release (ql-dist:provided-systems (ql-dist:find-dist \"quicklisp\"))))" &&\
    mv /usr/bin/sbcl /usr/bin/sbcl-binary

ADD image/root/start-sbcl /usr/bin/sbcl

ENTRYPOINT ["sbcl"]
