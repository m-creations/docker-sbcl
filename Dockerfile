## -*- docker-image-name: "mcreations/sbcl" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 1.3.16

ENV DOWNLOAD_URL http://prdownloads.sourceforge.net/sbcl

ENV DOWNLOAD_PACKAGE sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2

ENV SHA256_SUM 5ae49b7a6861781ef5f70eacfb4b423b79b5c7e7f8b1ddd6e40e7bcea96f026b

ENV QUICKLISP_HOME /opt/quicklisp

ENV XDG_CACHE_HOME /cache

RUN opkg update &&\
    opkg install \
         coreutils-sha256sum \
         gcc \
         make \
         zoneinfo-core &&\
    rm /etc/localtime &&\
    ln -s /usr/share/zoneinfo/UTC /etc/localtime &&\
    cd /tmp &&\
    wget --progress=dot:giga $DOWNLOAD_URL/$DOWNLOAD_PACKAGE &&\
    echo "$SHA256_SUM $DOWNLOAD_PACKAGE" | sha256sum -c &&\
    bunzip2 sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 &&\ 
    tar xvf sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar &&\
    cd sbcl-${SBCL_VERSION}-x86-64-linux &&\
    INSTALL_ROOT=/usr sh install.sh &&\
    mkdir -p /usr/local/lib &&\
    ln -s /usr/lib/sbcl /usr/local/lib/sbcl &&\
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
