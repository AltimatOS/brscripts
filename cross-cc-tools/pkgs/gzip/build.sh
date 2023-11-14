#!/bin/bash

set -e
set -u
set -o pipefail

NAME=gzip
VERSION=1.13
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://ftp.gnu.org/gnu/${NAME}/${NAME}-${VERSION}.tar.xz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    ./configure --prefix=/System --host=$BLD_TARGET
    make
    make DESTDIR=$BLDROOT install
popd

# clean up
rm *.xz
rm -rf $SRC_DIR
