#!/bin/bash

set -e
set -u
set -o pipefail

NAME=bash
VERSION=5.2.21
SOURCE0="${NAME}-${VERSION}.tar.gz"
SRC_DIR="${NAME}-${VERSION}"

# download package
curl -O "https://ftp.gnu.org/gnu/${NAME}/${NAME}-${VERSION}.tar.gz"

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    ./configure --prefix=/System --build=$(sh support/config.guess) --host=$BLD_TARGET --without-bash-malloc
    make
    make DESTDIR=$BLDROOT install

    # set bash as sh for now. Will move to zsh later
    ln -sv bash $BLDROOT/System/bin/sh
popd

rm *.gz
rm -rf $SRC_DIR

