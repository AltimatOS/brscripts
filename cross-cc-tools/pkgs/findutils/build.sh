#!/bin/bash

set -e
set -u
set -o pipefail

NAME=findutils
VERSION=4.9.0
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    ./configure --prefix=/System --localstatedir=/System/var/lib/locate --host=$BLD_TARGET --build=$(build-aux/config.guess)
    make
    make DESTDIR=$BLDROOT install
popd

# clean
rm *.xz
rm -rf $SRC_DIR
