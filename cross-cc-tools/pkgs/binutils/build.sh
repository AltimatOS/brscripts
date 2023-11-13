#!/bin/bash

set -e
set -u
set -o pipefail

NAME=binutils
VERSION=2.41
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# get binutils first
curl -O "https://ftp.gnu.org/gnu/binutils/$SOURCE0"

# unpack it
tar xvf "$SOURCE0"

# prep
pushd $SRC_DIR
    mkdir -v build
    pushd build
        ../configure --prefix=/AltimatOS/tools --with-sysroot=/AltimatOS --target=$BLD_TARGET --disable-nls --enable-gprofng=no --disable-werror --enable-multilib
        make
        make install
    popd
popd

# clean up
rm *.xz
rm -rf $SRC_DIR

