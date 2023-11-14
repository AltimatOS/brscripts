#!/bin/bash

set -e
set -u
set -o pipefail

NAME=glibc
VERSION=2.38
SOURCE0="${NAME}-${VERSION}.tar.xz"
PATCH0="glibc-2.38-fhs-1.patch"
SRC_DIR="${NAME}-${VERSION}"

# download sources
curl -O "https://ftp.gnu.org/gnu/glibc/$SOURCE0"

# unpack it
tar xvf $SOURCE0

pkg_root_dir=$(pwd)

pushd $SRC_DIR
    # first add a couple compatibility links for the build
    ln -sfv ../lib/ld-linux-x86-64.so.2 "$BLDROOT/lib64"
    ln -sfv ../lib/ld-linux-x86-64.so.2 "$BLDROOT/lib64/ld-lsb-x86-64.so.3"

    # patch to fix glibc's use of /var/db. This requires the OS compatibility links for now
    patch -N -p1 -i ../${NAME}-${VERSION}-fhs-1.patch

    # create build directory
    mkdir -p -v build
    pushd build
        echo "rootsbindir=/System/sbin" > configparms
        # configure it
        CC="$BLD_TARGET-gcc -m64" CXX="$BLD_TARGET-g++ -m64" \
        ../configure --prefix=/System --host=$BLD_TARGET --build=$(../scripts/config.guess) --enable-kernel=4.14 \
                 --with-headers=$BLDROOT/System/include --enable-multi-arch --libdir=/System/lib64 --libexecdir=/System/lib64 \
                 libc_cv_slibdir=/System/lib64

        # build it
        make

        # and install
        make DESTDIR=$BLDROOT install

        # small fix up for the ld script
        sed '/RTLDLIST=/s@/System@@g' -i $BLDROOT/System/bin/ldd

        # now, build 32-bit
        make clean
        find .. -name "*.a" -delete

        # reconfigure
        CC="$BLD_TARGET-gcc -m32" CXX="$BLD_TARGET-g++ -m32" \
        ../configure --prefix=/System --host=$BLD_TARGET32 --build=$(../scripts/config.guess) \
                     --enable-kernel=4.14 --with-headers=$BLDROOT/System/include --enable-multi-arch --libdir=/System/lib \
                     --libexecdir=/System/lib libc_cv_slibdir=/System/lib

	# build it again
        make

        # install
        make DESTDIR=$PWD/DESTDIR install
        cp -r -v DESTDIR/System/lib $BLDROOT/System/
        install -v -m 644 DESTDIR/System/include/gnu/{lib-names,stubs}-32.h $BLDROOT/System/include/gnu/
    popd
    # fix for symlink
    pushd $BLDROOT/System/lib
        ln -s /System/lib64/ld-linux-x86-64.so.2
    popd
popd

# clean up
rm *.xz
rm -rf $SRC_DIR

