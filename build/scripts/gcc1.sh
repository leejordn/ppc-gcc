#! /usr/bin/env bash

set -e
#set -u
#set -x # Uncomment to debug

source_name='gcc-14.2.0'
source scripts/common.sh
source host-env.sh

parse_cli "$@"
prepare_for_build \
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
    --prefix="$host_tools" \
    --target="$target" \
    --with-build-sysroot="$host_tools" \
    --with-newlib \
    --with-sysroot="$sysroot_prefix" \
    --without-cloog \
    --without-headers \
    --without-isl

cd "$build_dir"

make -j$(nproc) all-gcc LDFLAGS='-static'
make -j(nproc) install-gcc

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete

# We're gonna build this 4 times, so we'll need to move the directory
mv "$build_dir" stage-1-"$build_dir"
