#!/bin/bash -eux

#prereqs for oss-fuzz programs
xargs apt-get install --no-install-recommends -yqq <<EOF
    apt-utils
    autoconf
    autoconf-archive
    automake
    autopoint
    binutils-dev
    bison
    build-essential
    bzip2
    ccache
    cmake
    curl
    cvs 
    cvsps 
    default-jdk
    docbook-xsl 
    ffmpeg
    flex
    g++
    gcc
    gengetopt
    gettext
    git 
    gnutls-dev
    gperf    
    gawk
    jq
    libacl1
    libacl1-dev
    libbison-dev
    libbrotli-dev
    libbsd-dev
    libbz2-dev
    libbz2-dev:i386
    libc6-dev-i386
    libcap-ng-dev
    libcgi-pm-perl
    libconfig-dev
    libcunit1
    libcunit1-dev
    libcurl4-openssl-dev
    libcurlpp-dev 
    libdbd-sqlite3-perl 
    libdbus-1-dev
    libedit-dev
    liberror-perl 
    libexpat-dev
    libexpat1-dev 
    libffi-dev
    libfuse-dev
    libgcrypt20-dev
    libgc-dev
    libgdbm-dev
    libgmock-dev
    libgmp-dev
    libgnutls28-dev
    libhttp-date-perl
    libini-config-dev
    libinih-dev
    libio-pty-perl   
    libjansson-dev
    libjpeg-dev
    libjpeg-turbo8
    libjpeg-turbo8-dev
    libjpeg8
    libjpeg8-dev
    liblmdb-dev 
    liblz4-dev
    liblz4-dev:i386
    liblzma-dev
    liblzma-dev:i386
    libmailtools-perl
    libncurses5-dev 
    libncursesw5-dev
    libpam0g-dev
    libpcre2-dev
    libpcre3
    libpcre3-dev  
    libpci-dev
    libpng-dev
    libpq-dev
    libprotobuf-dev
    libreadline-dev
    libreadline-dev:i386
    libreadline6-dev
    libseccomp-dev
    libsqlite3-dev
    libssl-dev
    libssh-dev
    libssl1.1
    libstdc++-9-dev
    libsvn-perl
    libsystemd-dev
    libtool
    libtool-bin
    libudev-dev
    libunwind-dev
    libunwind-dev:i386
    libxml2-dev
    libxml2-utils
    libyaml-dev
    libyaml-perl 
    libz-dev 
    libzstd-dev
    libzstd-dev:i386
    lmdb-utils
    lrzsz
    m4
    make
    mercurial
    nasm
    ncurses-dev
    ninja-build
    openssl
    patch
    patchelf
    perl-modules
    pkg-config
    protobuf-compiler
    python   
    python-numpy
    re2c
    rsync
    ruby
    shtool
    subversion
    tcl
    texinfo
    tk-dev
    udev
    unzip
    uuid-dev
    wget
    xmlto 
    xsltproc
    yasm
    zip
    zlib1g-dev
    zlib1g-dev:i386
EOF

wget https://github.com/libexpat/libexpat/releases/download/R_2_4_1/expat-2.4.1.tar.gz && \
    tar -xf expat-2.4.1.tar.gz && \
    cd expat-2.4.1 && \
    ./configure && \
    make && \
    make install && \
    rm ../expat-2.4.1.tar.gz && \
    cd ..

xargs apt-get install -yqq <<EOF
    asciidoc
    firefox
    gtk-doc-tools
    libcurl4-gnutls-dev
    libdbus-glib-1-dev
    libgio2.0-cil-dev
    libglib2.0-dev   
    libpolkit-gobject-1-dev   
    libnice-dev
    light-locker-settings
    python3
    python3-all-dev
    python3-pip
    python-all-dev
EOF

xargs pip install <<EOF
    beautifulsoup4
    corpus-replicator
    contourpy
    cxxfilt
    cycler
    fonttools
    importlib-resources
    jinja2
    kiwisolver
    lxml
    matplotlib
    meson==1.2.3
    ninja
    numpy
    packaging
    pillow
    pyparsing
    python-dateutil
    pyyaml
    soupsieve
    zipp
    markupsafe
    Jinja2
    types-Jinja2
    jsonschema
    types-jsonschema
EOF

git clone https://github.com/PCRE2Project/pcre2 pcre2 && \
    cd pcre2 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ..

git clone https://github.com/ClusterLabs/libqb && \
    cd libqb && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ..
