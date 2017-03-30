## -*- docker-image-name: "mcreations/sbcl" -*-

FROM mcreations/openwrt-x64
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV SBCL_VERSION 1.3.16

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
    echo | sbcl --load /tmp/quicklisp.lisp --eval '(quicklisp-quickstart:install)' --eval '(quicklisp:add-to-init-file)' --eval '(sb-ext:quit)'

CMD ["sbcl"]
