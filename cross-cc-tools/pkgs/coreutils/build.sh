#!/bin/bash

set -e
set -u
set -o pipefail

NAME=coreutils
VERSION=9.4
SOURCE0="${NAME}-${VERSION}.tar.xz"
SRC_DIR="${NAME}-${VERSION}"

# download
curl -O https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz

# unpack
tar xvf $SOURCE0

pushd $SRC_DIR
    ./configure --prefix=/System --host=$BLD_TARGET --build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime
    make
    make DESTDIR=$BLDROOT install

    mv -v $BLDROOT/System/bin/chroot \
          $BLDROOT/System/sbin
    mkdir -pv $BLDROOT/System/share/man/man8
    mv -v $BLDROOT/System/share/man/man1/chroot.1 \
          $BLDROOT/System/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' $BLDROOT/System/share/man/man8/chroot.8
popd

# clean
rm *.xz
rm -rf $SRC_DIR
