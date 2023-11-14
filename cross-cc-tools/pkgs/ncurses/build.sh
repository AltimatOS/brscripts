#!/bin/bash

set -e
set -u
set -o pipefail

NAME=ncurses
VERSION=6.4
SOURCE0="${NAME}-${VERSION}.tar.gz"
SRC_DIR="${NAME}-${VERSION}"

# download package
curl -O https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    # make configure find gawk
    sed -i s/mawk// configure

    # build tic
    mkdir build
    pushd build
        ../configure
        make -C include
        make -C progs tic
    popd

    # configure it
    ./configure --prefix=/System --host=$BLD_TARGET --build=$(./config.guess) --libdir=/System/lib64 --mandir=/System/share/man --with-manpage-format=normal \
                --with-shared --without-normal --with-cxx-shared --without-debug --without-ada --disable-stripping  --enable-widec

    # build it
    make

    # install
    make DESTDIR=$BLDROOT TIC_PATH=$(pwd)/build/progs/tic install
    echo "INPUT(-lncursesw)" > $BLDROOT/System/lib/libncurses.so

    # Now, deal with 32bit
    make distclean

    CC="$LFS_TGT-gcc -m32" CXX="$LFS_TGT-g++ -m32" \
    ./configure --prefix=/System --host=$BLD_TARGET32 --build=$(./config.guess) --libdir=/System/lib --mandir=/System/share/man --with-shared --without-normal \
                --with-cxx-shared --without-debug --without-ada --disable-stripping --enable-widec

    # build 32-bit
    make

    # install 32-bit
    make DESTDIR=$PWD/DESTDIR TIC_PATH=$(pwd)/build/progs/tic install
    ln -s libncursesw.so DESTDIR/System/lib/libcursesw.so
    cp -Rv DESTDIR/System/lib/* $BLDROOT/System/lib
    rm -rf DESTDIR
popd

# clean up
rm *.gz
rm -rf $SRC_DIR
