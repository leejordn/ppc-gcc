#! /usr/bin/env bash

set -e
#set -u
#set -x # Uncomment to debug

source_name='binutils-2.44'
source scripts/common.sh
source host-env.sh

# Capable of understanding [32/64] bit [little/big] endian [bare-metal/linux] systems. 64 bit
# embedded linux not supported by GNU, though
binutils_targets="\
powerpc-linux-gnu,\
powerpcle-linux-gnu,\
powerpc64-linux-gnu,\
powerpc64le-linux-gnu,\
powerpc-eabi,\
powerpcle-eabi"

parse_cli $*
prepare_for_build \
    --disable-doc \
    --disable-gdb \
    --disable-gdbtk \
    --disable-nls \
    --disable-shared \
    --disable-tui \
    --disable-werror \
    --enable-64-bit-bfd \
    --enable-gold \
    --enable-initfini-array \
    --enable-plugins \
    --enable-targets="$binutils_targets" \
    --enable-year2038 \
    --host="$(gcc -dumpmachine)" \
    --prefix="$host_tools" \
    --target="$target" \
    --with-build-sysroot="$host_tools" \
    --with-sysroot="$sysroot_prefix" \
    --without-debuginfod \
    --without-gdb \
    --without-python \
    --without-x \
    ac_cv_search_dlopen=no


cd "$build_dir"
make -j$(nproc) configure-host
make -j$(nproc) LDFLAGS='-all-static'
make install

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete
