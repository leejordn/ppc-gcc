#! /usr/bin/env bash

set -e
#set -u
#set -x # Uncomment to debug

source_name='glibc-2.19'
source scripts/common.sh
source cross-env.sh

export BUILD_CC=gcc

parse_cli "$@"
export CFLAGS="-O2 -mcpu=7450 -mtune=7450 -maltivec -mabi=altivec -fcommon"
prepare_for_build \
    --build="$(gcc -dumpmachine)" \
    --disable-bounded \
    --disable-omitfp \
    --disable-nls \
    --disable-profile \
    --disable-werror \
    --enable-crypt \
    --enable-kernel="2.6.27" \
    --enable-obsolete-rpc \
    --enable-shared \
    --host="$target" \
    --includedir=/usr/include \
    --prefix=/usr \
    --with-headers="$sysroot/usr/include" \
    --with-tls \
    --without-cvs \
    --without-gd \
    --without-selinux \
    libc_cv_visibility_attribute=yes \
    libc_cv_broken_visibility_attribute=no \
    libc_cv_forced_unwind=yes \
    libc_cv_slibdir=/usr/lib \
    libc_cv_rtlddir=/lib

# --disable-sanity-checks \

PATH="$host_tools/bin:$PATH"
pwd
# There seems to be race conditions for parallel builds =( so no -j
make -C "$source_name"
make -C "$source_name" \
     install_root="$sysroot" \
     INSTALL="$(which install)" \
     install

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete
