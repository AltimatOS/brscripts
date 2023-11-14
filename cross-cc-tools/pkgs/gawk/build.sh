#!/bin/bash

set -e
set -u
set -o pipefail

NAME=gawk
VERSION=5.3.0
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    # don't install extras
    sed -i 's/extras//' Makefile.in

    ./configure --prefix=/System --host=$BLD_TARGET --build=$(build-aux/config.guess)
    make
    make DESTDIR=$BLDROOT install
popd

# clean up
rm *.xz
rm -rf $SRC_DIR
