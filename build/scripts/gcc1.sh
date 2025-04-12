#! /usr/bin/env bash

set -e
set -u
#set -x # Uncomment to debug

source_name='gcc-14.2.0'
source scripts/common.sh
source host-env.sh

parse_cli "$@"
prepare_for_build \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libmidflap \
    --disable-libquadmath \
    --disable-libsanitizer \
    --disable-libssp \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --enable-checking=yes \
    --enable-languages=c \
    --prefix='/' \
    --target="$target" \
    --with-build-sysroot="$host_tools" \
    --with-newlib \
    --with-sysroot="$sysroot_prefix" \
    --without-cloog \
    --without-headers \
    --without-isl

cd "$build_dir"

# `gold` uses CXX to link, which doesn't understand the undocumented '-all-static' `ld` flag that
# binutils needs to compile completely statically, so it needs to be compiled separately. There is
# also an undocumented '--with-gold-ldflags=' configure option, but I decided to only use 1
# undocumented flag today.
make -j$(nproc) -C gold LDFLAGS='-static'
make -j$(nproc) LDFLAGS='-all-static'
make -j(nproc) install DESTDIR="$host_tools"

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete
