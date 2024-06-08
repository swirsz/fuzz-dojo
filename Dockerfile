# syntax=docker/dockerfile:1

FROM pwncollege-challenge

USER root

################################################################################

# From oss-fuzz/infra/base-images/base-image, base-clang, base-builder, base-runner

ENV OUT=/out
ENV SRC=/src
ENV WORK=/work
WORKDIR $SRC

RUN mkdir -p $OUT $SRC $WORK /corpus && chmod a+rwx $OUT $SRC $WORK

RUN apt-get update && apt-get upgrade -y && \
    xargs apt-get install -yqq git pip

RUN git clone https://github.com/google/oss-fuzz /opt/oss-fuzz && \
    cd /opt/oss-fuzz && \
    git checkout 9c47164550b631f39c4923c73f98c9fc6ef611e8

RUN cd $SRC && \
    git clone https://github.com/google/fuzztest && \
    cd fuzztest && \
    git checkout a37d133f714395cabc20dd930969a889495c9f53 && \
    rm -rf .git

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-431.0.0-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-431.0.0-linux-x86_64.tar.gz && \
    ./google-cloud-sdk/install.sh && \
    rm google-cloud-cli-431.0.0-linux-x86_64.tar.gz

RUN git clone https://chromium.googlesource.com/chromium/src/tools/code_coverage /opt/code_coverage && \
    cd /opt/code_coverage && \
    git checkout edba4873b5e8a390e977a64c522db2df18a8b27d && \
    pip install wheel && \
    pip install -r requirements.txt && \
    pip install MarkupSafe==0.23 && \
    pip install coverage 

RUN cd $SRC && \
    git clone https://github.com/AFLplusplus/AFLplusplus.git aflplusplus && \
    cd aflplusplus && \
    git checkout 0688c779ec543c4f5f84363b06c72ac11a14f716 && \
    wget --no-check-certificate -O oss.sh https://raw.githubusercontent.com/vanhauser-thc/binary_blobs/master/oss.sh && \
    rm -rf .git && \
    chmod 755 oss.sh
    
RUN xargs apt-get install -yqq \
    libc6-dev \
    libgcc-9-dev \
    libnice-dev \
    patch \
    subversion \
    sudo \
    tzdata \
    wget

################################################################################

ADD https://commondatastorage.googleapis.com/clusterfuzz-builds/jcc/clang-jcc /usr/local/bin/
ADD https://commondatastorage.googleapis.com/clusterfuzz-builds/jcc/clang++-jcc /usr/local/bin/

RUN cp /opt/oss-fuzz/infra/base-images/base-builder/bazel_build_fuzz_tests \
    /opt/oss-fuzz/infra/base-images/base-builder/cargo \
    /opt/oss-fuzz/infra/base-images/base-builder/compile \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_afl \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_centipede \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_honggfuzz \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_fuzztests.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_go_fuzzer \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_javascript_fuzzer \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_libfuzzer \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_native_go_fuzzer \
    /opt/oss-fuzz/infra/base-images/base-builder/compile_python_fuzzer \
    /opt/oss-fuzz/infra/base-images/base-builder/debug_afl \
    # Go, JavaScript, Java, Python, Rust, and Swift installation scripts.
    /opt/oss-fuzz/infra/base-images/base-builder/install_go.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/install_javascript.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/install_java.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/install_python.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/install_rust.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/install_swift.sh \
    /opt/oss-fuzz/infra/base-images/base-builder/python_coverage_helper.py \
    /opt/oss-fuzz/infra/base-images/base-builder/srcmap \
    /opt/oss-fuzz/infra/base-images/base-builder/write_labels.py \
    /usr/local/bin/

COPY sbin/compile_afl.patch /usr/local/bin/
RUN patch -tuN /usr/local/bin/compile_afl -i /usr/local/bin/compile_afl.patch -r -

RUN cp /opt/oss-fuzz/infra/base-images/base-runner/bad_build_check \
    /opt/oss-fuzz/infra/base-images/base-runner/coverage \
    /opt/oss-fuzz/infra/base-images/base-runner/coverage_helper \
    /opt/oss-fuzz/infra/base-images/base-runner/download_corpus \
    /opt/oss-fuzz/infra/base-images/base-runner/jacoco_report_converter.py \
    /opt/oss-fuzz/infra/base-images/base-runner/nyc_report_converter.py \
    /opt/oss-fuzz/infra/base-images/base-runner/rcfilt \
    /opt/oss-fuzz/infra/base-images/base-runner/reproduce \
    /opt/oss-fuzz/infra/base-images/base-runner/run_fuzzer \
    /opt/oss-fuzz/infra/base-images/base-runner/parse_options.py \
    /opt/oss-fuzz/infra/base-images/base-runner/profraw_update.py \
    /opt/oss-fuzz/infra/base-images/base-runner/targets_list \
    /opt/oss-fuzz/infra/base-images/base-runner/test_all.py \
    /opt/oss-fuzz/infra/base-images/base-runner/test_one.py \
    /opt/oss-fuzz/infra/base-images/base-runner/python_coverage_runner_help.py \
    /usr/local/bin/

RUN cp /opt/oss-fuzz/infra/base-images/base-builder/llvmsymbol.diff $SRC
RUN cp /opt/oss-fuzz/infra/base-images/base-builder/bazel.bazelrc /root/.bazelrc

RUN cp /opt/oss-fuzz/infra/base-images/base-builder/precompile_afl /usr/local/bin/
COPY sbin/precompile_afl.patch /usr/local/bin/
RUN patch -tuN /usr/local/bin/precompile_afl -i /usr/local/bin/precompile_afl.patch -r -
RUN precompile_afl

ENV DEBIAN_FRONTEND noninteractive
ARG arch=x86_64
WORKDIR $SRC

# Install newer cmake.
ENV CMAKE_VERSION 3.24.2
RUN wget -q https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-Linux-$arch.sh && \
    chmod +x cmake-$CMAKE_VERSION-Linux-$arch.sh && \
    ./cmake-$CMAKE_VERSION-Linux-$arch.sh --skip-license --prefix="/usr/local" && \
    rm cmake-$CMAKE_VERSION-Linux-$arch.sh && \
    rm -rf /usr/local/doc/cmake /usr/local/bin/cmake-gui

WORKDIR /

RUN git clone https://github.com/ossf/fuzz-introspector.git fuzz-introspector && \
    cd fuzz-introspector && \
    git checkout cfb5266a4c45cbec8663bb1b215c7fd326c60901 && \
    git submodule init && \
    git submodule update

RUN cp /opt/oss-fuzz/infra/base-images/base-clang/checkout_build_install_llvm.sh /root/
RUN /root/checkout_build_install_llvm.sh
RUN rm /root/checkout_build_install_llvm.sh

COPY sbin/download.sh /opt
RUN /opt/download.sh
RUN rm /opt/download.sh

WORKDIR $SRC

#prereqs for oss-fuzz programs
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && xargs apt-get install --no-install-recommends -yqq <<EOF && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
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
        gawk
        gcc
        gengetopt
        gettext
        git 
        gnutls-dev
        gperf    
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
        libgc-dev
        libgcrypt20-dev
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
        libpci-dev
        libpcre2-dev
        libpcre3
        libpcre3-dev  
        libpng-dev
        libpq-dev
        libprotobuf-dev
        libreadline-dev
        libreadline-dev:i386
        libreadline6-dev
        libseccomp-dev
        libsqlite3-dev
        libssh-dev
        libssl-dev
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

RUN wget https://github.com/libexpat/libexpat/releases/download/R_2_4_1/expat-2.4.1.tar.gz && \
    tar -xf expat-2.4.1.tar.gz && \
    cd expat-2.4.1 && \
    ./configure && \
    make && \
    make install && \
    rm ../expat-2.4.1.tar.gz && \
    cd ..

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && xargs apt-get install -yqq <<EOF && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
        asciidoc
        firefox
        gtk-doc-tools
        libcurl4-gnutls-dev
        libdbus-glib-1-dev
        libdrm-dev
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

RUN xargs pip install <<EOF
        beautifulsoup4
        contourpy
        corpus-replicator
        cxxfilt
        cycler
        fonttools
        importlib-resources
        Jinja2
        jsonschema
        kiwisolver
        lxml
        markupsafe
        matplotlib
        meson==1.2.3
        ninja
        numpy
        opencv-python
        packaging
        pillow
        pyparsing
        python-dateutil
        pyyaml
        soupsieve
        Twisted
        types-Jinja2
        types-jsonschema
        vncdotool
        zipp
        zope.interface
EOF

RUN git clone https://github.com/PCRE2Project/pcre2 pcre2 && \
    cd pcre2 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ..

RUN git clone https://github.com/ClusterLabs/libqb && \
    cd libqb && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ..

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && xargs apt-get install --no-install-recommends -yqq <<EOF && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
        arping
        binutils
        binutils-aarch64-linux-gnu
        binwalk
        bsdmainutils
        bsdutils
        debianutils
        diffutils
        ed
        elfutils
        emacs
        ethtool
        exiftool
        expect
        findutils
        fish
        fortune
        gcc-aarch64-linux-gnu
        gdb
        gdb-multiarch
        gedit
        genisoimage
        gnupg-utils
        hexedit
        iproute2
        iputils-ping
        ipython3
        keyutils
        kmod
        less
        libc6-arm64-cross
        libc6-dev-arm64-cross
        ltrace
        nano
        neovim
        net-tools
        netcat-openbsd
        nmap
        openssh-server
        parallel
        pcaputils
        pcre2-utils
        psutils
        python3-ipdb
        qemu-system-x86
        qemu-user
        qemu-utils
        screen
        silversearcher-ag
        strace
        tmux
        whiptail
        wireshark
        zsh
EOF

COPY sbin/none \
     sbin/address \
     sbin/memory \
     sbin/thread \
     sbin/undefined \
     sbin/cover \
     sbin/inspector \
     sbin/find-drv \
     sbin/e \
     sbin/eafl \
     sbin/loc-calc \
     sbin/reports \
     sbin/fi \
     sbin/drivers \
     sbin/loc_count \
     sbin/loc_count2 \
     sbin/loc_count120 \
     sbin/test-crashes \
     sbin/announce \
     sbin/fuzz_report.patch \
     /usr/local/sbin/

USER hacker
WORKDIR /home/hacker
