#!/bin/bash

set -e
set -u
set -o pipefail

NAME=gcc
VERSION=13.2.0
SOURCE0="${NAME}-${VERSION}.tar.xz"
SOURCE1="gmp-6.3.0.tar.xz"
SOURCE2="mpc-1.3.1.tar.gz"
SOURCE3="mpfr-4.2.1.tar.xz"

SRC_DIR="${NAME}-${VERSION}"

# get the packages needed
# gcc
curl -O https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
curl -O https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
curl -O https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz

# now unpack gcc
tar xvf $SOURCE0

pushd $SRC_DIR
    tar xvf ../$SOURCE1
    mv -v gmp-6.3.0 gmp
    tar xvf ../$SOURCE2
    mv -v mpc-1.3.1 mpc
    tar xvf ../$SOURCE3
    mv -v mpfr-4.2.1 mpfr

    mkdir -v build
    pushd build
        # now configure the package
        mlist=m64,m32
        ../configure  --target=$BLD_TARGET --prefix=$BLDROOT/tools --with-glibc-version=2.38 --with-sysroot=$BLDROOT --with-newlib --without-headers \
                      --enable-default-pie --enable-default-ssp --enable-initfini-array --disable-nls --disable-shared --enable-multilib --with-multilib-list=$mlist \
                      --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv \
                      --disable-libstdcxx --enable-languages=c,c++
        make
        make install
    popd

    # fix up for the limits.h header
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
      $(dirname $($BLD_TARGET-gcc -print-libgcc-file-name))/include/limits.h
popd

# clean up
rm *.gz
rm *.xz
rm -rf $SRC_DIR

