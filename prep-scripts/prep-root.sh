#!/bin/bash

set -e
set -u
set -o pipefail

for DIR in "Applications" "System" "Users" "Volumes"; do
    install -d -m 755 -o root -g root "/AltimatOS/$DIR"
done

# create the common tree
install -d -m 755 -o root -g root /AltimatOS/Applications/Common
install -d -m 755 -o root -g root /AltimatOS/Applications/Common/bin
install -d -m 755 -o root -g root /AltimatOS/Applications/Common/lib
install -d -m 755 -o root -g root /AltimatOS/Applications/Common/lib64
install -d -m 755 -o root -g root /AltimatOS/Applications/Common/share

# Now for the System tree
pushd /AltimatOS/System
    for DIR in "bin" "boot" "boot/efi" "cfg" "dev" "include" "lib" "lib64" "proc" "run" "run/lock" "sbin" "share" "selinux" "sys" "var"; do
        install -d -m 755 -o root -g root "$DIR"
    done
    # special case tmp
    install -d -m 1777 -o root -g root tmp

    # var tree
    pushd var
        for DIR in "cache" "crash" "lib" "log" "spool"; do
            install -d -m 755 -o root -g root "$DIR"
        done
        # special case root and tmp
        install -d -m 700 -o root -g root root
        install -d -m 1777 -o root -g root tmp
        install -d -m 1777 -o root -g root spool/mail
    popd
popd

# Users
pushd /AltimatOS/Users
    install -d -m 700 -o root -g root Administrator
    install -d -m 775 -o root -g users Shared
popd

# symlinks
pushd /AltimatOS
    ln -s /System/bin bin
    ln -s /System/dev dev
    ln -s /System/cfg etc
    ln -s /System/lib lib
    ln -s /System/lib64 lib64
    ln -s /System/proc proc
    ln -s /System/run run
    ln -s /System/sbin sbin
    ln -s /System/selinux selinux
    ln -s /System/sys sys
    ln -s /System usr
    ln -s /System/tmp tmp
    ln -s /System/var var
    ln -s /System/var/root root
    ln -s Users home
    pushd System
        ln -s cfg etc
        pushd var
            ln -s /System/run/lock lock
            ln -s /System/var/spool/mail mail
            ln -s /System/run run
        popd
    popd
popd
