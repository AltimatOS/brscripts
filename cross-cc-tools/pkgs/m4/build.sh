#!/bin/bash

set -e
set -u
set -o pipefail

NAME=m4
VERSION=1.4.19
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# download package
curl -O https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    ./configure --prefix=/usr   \
            --host=$BLD_TARGET \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$BLDROOT install
popd

# clean up
rm *.xz
rm -rf $SRC_DIR

