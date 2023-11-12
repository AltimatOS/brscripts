#!/bin/bash

set -e
set -u
set -o pipefail

if [[ -z "$(getent group builders)" ]]; then
    echo "Adding group: builders"
    groupadd builders
    if [[ -z "$(getent passwd builder)" ]]; then
        echo "Adding user: builder"
        useradd -s /bin/bash -g builders -d /Users/builder -M -N builder
        mkdir -pv /Users/builder
        chown -v builder:builders /Users/builder
        if [[ ! -f /etc/sudoers.d/builder ]]; then
            echo "builder All=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
            chown -v root:root /etc/sudoers.d/builder
            chmod -v 600 /etc/sudoers.d/builder
        fi
        echo "Adding password for builder user"
        passwd builder
        echo "Adding bash profile configuration"
        su -p -s /bin/bash -g builders -c "echo 'exec env -i HOME=/Users/builder TERM=linux PS1=\'\u:\w\$ \' /bin/bash' > ~/.bash_profile" builder

        # have to do this with cat, since it is too long
	cat > ~builder/.bashrc << "EOF"
set +h
umask 022
BLDROOT=/AltimatOS
HOME=/Users/builder
LC_ALL=POSIX
PATH=/cross-tools/bin:/bin:/usr/bin
export BLDROOT LC_ALL PATH HOME
unset CFLAGS CXXFLAGS PKG_CONFIG_PATH

# build variables
BLD_HOST=$(echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/')
BLD_TARGET="x86_64-unknown-linux-gnu"
BLD_TARGET32="i686-pc-linux-gnu"
BUILD32="-m32"
BUILD64="-m64"

# now export the vars
export BLD_HOST
export BLD_TARGET
export BLD_TARGET32
export BUILD32
export BUILD64
EOF
        # correct permissions
        chown -v builder:builders ~builder/.bashrc
        chmod -v 600 ~builder/.bashrc

        # create dirs and symlinks
        su -p -s /bin/bash -g builders -c ./create-dirs-and-links.sh builder
    fi
else
    echo "User and group appear to be available already. Exiting"
    exit 0
fi
