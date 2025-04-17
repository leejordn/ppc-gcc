#! /usr/bin/env bash

set -e
#set -u
#set -x # Uncomment to debug

source_name='glibc-2.19'
source scripts/common.sh
source cross-env.sh

verify_msys

# Linaro stuff
export AUTOCONF=no
export CC="$target-gcc"
export CXX="$target-g++"
export AR="$target-ar"
export RANLIB="$target-ar"

export BUILD_CC=gcc
export BUILD_CPPFLAGS=""
export BUILD_CFLAGS=""

# Linaro does this but never defines the variables?
# libc_cv_slibdir=$libc_cv_slibdir
# libc_cv_rtlddir=$libc_cv_rtlddir

parse_cli "$@"

prepare_for_build \
    --disable-bounded \
    --disable-omitfp \
    --disable-profile \
    --disable-sanity-checks \
    --disable-werror \
    --enable-crypt \
    --enable-kernel="2.6.27" \
    --enable-obsolete-rpc \
    --enable-shared \
    --host="$target" \
    --includedir=/usr/include \
    --prefix=/usr \
    --target="$target" \
    --with-headers="$sysroot/usr/include" \
    --with-tls \
    --without-cvs \
    --without-gd \
    --without-selinux \
    libc_cv_visibility_attribute=yes \
    libc_cv_broken_visibility_attribute=no \
    libc_cv_forced_unwind=yes

make -C "$source_name" \
     install-bootstrap-headers=yes \
     install_root="$sysroot" \
     INSTALL="$(which install)" \
     install-headers

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete
