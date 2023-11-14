#!/bin/bash

set -e
set -u
set -o pipefail

NAME=make
VERSION=4.4.1
SOURCE0="${NAME}-${VERSION}.tar.lz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://ftp.gnu.org/gnu/${NAME}/${NAME}-${VERSION}.tar.lz

# unpack
lzip -d $SOURCE0
tar xvf ${NAME}-${VERSION}.tar

pushd $SRC_DIR
    ./configure --prefix=/System --without-guile --host=$BLD_TARGET --build=$(build-aux/config.guess)
    make
    make DESTDIR=$BLDROOT install
popd

# clean up
rm *.tar
rm -rf $SRC_DIR
