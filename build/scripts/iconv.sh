#! /usr/bin/env bash

set -e
set -u
#set -x # Uncomment to debug

source_name='libiconv-1.18'
source scripts/common.sh
source host-env.sh

echo "Using host tools in: \"$host_tools\""
parse_cli $*
prepare_for_build \
    --disable-shared \
    --enable-static \
#    --prefix="/" \
    --prefix="$host_tools" \
    --with-sysroot="$host_tools"

    #am_cv_lib_iconv=no
    # gl_cv_func_working_iconv=no \
    # am_cv_func_iconv=no \

cd "$build_dir"
# -j is making this build fail for some reason? It tries to use an absolute path for windres
make
make install #DESTDIR="$host_tools"

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete
