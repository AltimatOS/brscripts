#!/bin/bash

set -e
set -u
set -o pipefail

NAME=file
VERSION=5.45
SOURCE0="${NAME}-${VERSION}.tar.gz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://astron.com/pub/file/file-5.45.tar.gz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    mkdir build
    pushd build
        ../configure --disable-bzlib  --disable-libseccomp --disable-xzlib --disable-zlib
        make
    popd

    ./configure --prefix=/System --host=$BLD_TARGET --build=$(./config.guess)
    make FILE_COMPILE=$(pwd)/build/src/file
    make DESTDIR=$BLDROOT install
    rm -v $BLDROOT/System/lib/libmagic.la
popd

# clean up
rm *.gz
rm -rf $SRC_DIR
