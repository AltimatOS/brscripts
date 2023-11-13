#!/bin/bash

set -e
set -u
set -o pipefail

NAME=linux
VERSION=6.6.1
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# get source
curl -O "https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/$SOURCE0"

# unpack it
tar xvf $SOURCE0

pushd $SRC_DIR
    # clean sources
    make mrproper

    # make headers
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -r -v usr/include $BLDROOT/System
popd

# clean up
rm *.xz
rm -rf $SRC_DIR

