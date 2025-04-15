#! /usr/bin/env bash

set -e
#set -u
#set -x # Uncomment to debug

source_name='mpc-1.2.1'
source scripts/common.sh
source host-env.sh

verify_ucrt64

# Flags I'm not sure about
_prefix="$host_tools"

echo "Using host tools in: \"$host_tools\""
parse_cli "$@"
prepare_for_build \
    --disable-maintainer-mode \
    --disable-shared \
    --enable-static \
    --prefix="$host_tools" \
    --with-gmp="$host_tools" \
    --with-mpfr="$host_tools"

cd "$build_dir"
make -j$(nproc)
make -j$(nproc) install #DESTDIR="$host_tools"

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
# find "$host_tools" -name '*.la' -delete
