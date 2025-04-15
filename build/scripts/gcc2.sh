#! /usr/bin/env bash

####
# Stage 1's `make install-gcc` output contains the following snippet:
#
# > Libraries have been installed in:
# >    /d/dev/cross/powerpc-linux-gnu/build/host-tools/libexec/gcc/powerpc-linux-gnu/14.2.0
# >
# > If you ever happen to want to link against installed libraries
# > in a given directory, LIBDIR, you must either use libtool, and
# > specify the full pathname of the library, or use the `-LLIBDIR'
# > flag during linking and do at least one of the following:
# >    - add LIBDIR to the `PATH' environment variable
# >      during execution
# >    - add LIBDIR to the `LD_RUN_PATH' environment variable
# >      during linking
# >    - use the `-LLIBDIR' linker flag


#set -e
#set -u
#set -x # Uncomment to debug

gcc_version="14.2.0"
source_name="gcc-${gcc_version}"
source scripts/common.sh
source host-env.sh

# NOTE ABOUT THE --prefix CONFIGURE FLAG:
#
# Using an absolute path for this option is definitely not the original intention — but MSYS2's
# pseudo-Unix path handling breaks the expected behavior completely.
#
# - Setting it to '/' causes MSYS2 to interpret it as a UNC path ('//'), which GCC and binutils do
#   not understand. This results in bizarre -B and -isystem search paths like
#   //powerpc-linux-gnu/lib.
#
# - Disabling it entirely with '--prefix=' or '--prefix=""' causes autoconf to fall back to the
#   default '/'. MSYS2 interprets that as the root of the current environment — typically '/ucrt64',
#   '/mingw64', or another active subsystem.
#
#   The solution: set --prefix to an absolute path (e.g. /d/dev/cross/toolchain). This avoids MSYS2
#   rewriting and gives GCC stable internal paths.
#
# What this changes:
#
# 1. It hardcodes the installation path into GCC’s build system. You can no longer use DESTDIR as a
#    staging root unless you patch libtool.
#
# 2. It hardcodes the install path into .la (libtool archive) files, which can break relocatability
#    in rare situations.
#
# Fortunately, libtool archives are widely regarded as harmful. Many distros — including Debian,
# Arch, and Fedora — routinely delete .la files during packaging or even on boot. You're safe to do
# the same.
#
# Bottom line: On MSYS2, --prefix must be absolute if you want reliable behavior. DESTDIR-based
# installs and flat prefixes ('/') are simply not portable here.

parse_cli "$@"
prepare_for_build \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libmudflap \
    --disable-libquadmath \
    --disable-libssp \
    --disable-nls \
    --enable-languages=c \
    --enable-mingw-wildcard \
    --enable-shared \
    --prefix="/" \
    --target="$target" \
    --with-build-sysroot="$sysroot" \
    --with-libiconv-prefix="$host_tools" \
    --with-sysroot="$sysroot_prefix" \
    --without-cloog \
    --without-isl

    # --with-native-system-header-dir="/usr/include" \
    # --enable-checking=yes \

make -C "$build_dir" -j$(nproc) LDFLAGS='-static'
make -C "$build_dir" -j$(nproc) DESTDIR="$toolchain" INSTALL=$(command -v install) install

     # FLAGS_FOR_TARGET="-I $sysroot/usr/include -I $sysroot/include -I $sysroot/$target/include" \
# # Force normal include directories - the ones that were built into the binary are screwed because of
# # GCC's pseudo-Unix path deduction
# cat "$build_dir/gcc/specs" \
#     | sed '/^\*cpp_unique_options:/,/^$/ s|%I|%I %{!nostdinc:-isystem %R/usr/include -isystem %R/include -isystem %R/usr/local/include}|' \
#           > "$toolchain/lib/gcc/powerpc-linux-gnu/$gcc_version/specs"

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete

# We're gonna build this 4 times, so we'll need to move the directory
mv "$source_name" "stage-2-$source_name"
