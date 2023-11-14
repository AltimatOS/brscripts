#!/bin/bash

set -e
set -u
set -o pipefail

NAME='libstdc++'
VERSION=13.2.0
SOURCE0="gcc-${VERSION}.tar.xz"
SRC_DIR="gcc-${VERSION}"

# get the packages needed
# gcc
curl -O https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz

# now unpack gcc
tar xvf $SOURCE0

pushd $SRC_DIR
    mkdir -v build
    pushd build
        # now configure the package
        ../libstdc++-v3/configure --host=${BLD_TARGET} --build=$(../config.guess) \
                                  --prefix=/System --enable-multilib --disable-nls \
                                  --disable-libstdcxx-pch \
                                  --with-gxx-include-dir=/tools/${BLD_TARGET}/include/c++/${VERSION}
        make
        make DESTDIR=$BLDROOT install
    popd
    rm -v $BLDROOT/System/lib/lib{stdc++{,exp,fs},supc++}.la
popd

# clean up
rm *.xz
rm -rf $SRC_DIR


