#! /usr/bin/env bash

set -euo pipefail
#set -x # Uncomment to debug

script_source=${BASH_SOURCE[0]}
while [ -L "$script_source" ]; do
    script_parent=$( cd -P "$( dirname "$script_source" )" >/dev/null 2>&1 && pwd )
    script_source=$(readlink "$script_source")
    [[ $script_source != /* ]] && script_source=$script_parent/$script_source
done
script_parent=$( cd -P "$( dirname "$script_source" )" >/dev/null 2>&1 && pwd )
source "$script_parent/project_defs.sh"
unset script_parent
unset script_source


verify_ucrt64
use_host_env

# Capable of understanding [32/64] bit [little/big] endian [bare-metal/linux] systems. 64 bit
# embedded linux not supported by GNU, though
binutils_targets="\
powerpc-linux-gnu,\
powerpcle-linux-gnu,\
powerpc64-linux-gnu,\
powerpc64le-linux-gnu,\
powerpc-eabi,\
powerpcle-eabi"

select_source 'binutils-2.44'
do_clean
do_configure \
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
    --prefix="$toolchain" \
    --target="$target" \
    --with-build-sysroot="$host_tools" \
    --with-sysroot="$sysroot_prefix" \
    --without-debuginfod \
    --without-gdb \
    --without-python \
    --without-x \
    ac_cv_search_dlopen=no


do_make -j$(nproc) configure-host
do_make -j$(nproc) LDFLAGS='-all-static'
do_make -j$(nproc) install

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
find "$host_tools" -name '*.la' -delete
