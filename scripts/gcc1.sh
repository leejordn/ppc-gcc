#! /usr/bin/env bash

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  IMPORTANT:
#    The following patches need to be applied before this script will work:
#    - gcc-14.2.0-default-specs.patch
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

select_source 'gcc-14.2.0'
do_clean
do_configure \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libmudflap \
    --disable-libquadmath \
    --disable-libsanitizer \
    --disable-libssp \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --enable-checking=yes \
    --enable-languages=c \
    --enable-mingw-wildcard \
    --prefix="$toolchain" \
    --target="$target" \
    --with-build-sysroot="$host_tools" \
    --with-newlib \
    --with-sysroot="$sysroot_prefix" \
    --without-cloog \
    --without-headers \
    --without-isl


do_make -j$(nproc) all-gcc LDFLAGS='-static'
do_make -j$(nproc) install-gcc

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
find "$host_tools" -name '*.la' -delete

# We're gonna build this 4 times, so we'll need to move the directory
mv "$build_path" stage-1-"$build_path"
