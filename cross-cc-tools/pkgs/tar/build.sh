#!/bin/bash

set -e
set -u
set -o pipefail

NAME=tar
VERSION=1.35
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://ftp.gnu.org/gnu/${NAME}/${NAME}-${VERSION}.tar.xz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    ./configure --prefix=/System --host=$BLD_TARGET --build=$(build-aux/config.guess)
    make
    make DESTDIR=$BLDROOT install
popd

# clean up
rm *.xz
rm -rf $SRC_DIR
