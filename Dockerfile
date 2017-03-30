## -*- docker-image-name: "mcreations/sbcl" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 1.3.16

ENV QUICKLISP_HOME /opt/quicklisp

ENV XDG_CACHE_HOME /cache

RUN opkg update &&\
    opkg install \
         gcc \
         make \
         zoneinfo-core &&\
    rm /etc/localtime &&\
    ln -s /usr/share/zoneinfo/UTC /etc/localtime &&\
    wget --progress=dot:giga http://prdownloads.sourceforge.net/sbcl/sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 &&\
    bunzip2 sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 &&\ 
    tar xvf sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar &&\
    cd sbcl-${SBCL_VERSION}-x86-64-linux &&\
    INSTALL_ROOT=/usr sh install.sh &&\
    mkdir -p /usr/local/lib &&\
    ln -s /usr/lib/sbcl /usr/local/lib/sbcl &&\
    cd &&\
    rm /tmp/opkg-lists/* &&\
    rm -rf /sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar /sbcl-${SBCL_VERSION}-x86-64-linux &&\
    wget -O /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp &&\
    mkdir /opt &&\
    mkdir -p /common-lisp &&\
    mkdir -p /usr/share/common-lisp  &&\
    mkdir -p $XDG_CACHE_HOME &&\
    ln -s /common-lisp /usr/share/common-lisp/source &&\
    echo | sbcl --load /tmp/quicklisp.lisp --eval '(quicklisp-quickstart:install :path "/opt/quicklisp")' --eval '(quicklisp:add-to-init-file)' --eval '(sb-ext:quit)'

CMD ["sbcl"]
