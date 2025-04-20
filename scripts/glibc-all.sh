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
use_cross_env

export BUILD_CC=gcc
export BUILD_CFLAGS="-O2"
export CFLAGS="-O2 -mcpu=7450 -mtune=7450 -maltivec -mabi=altivec -fcommon"

select_source 'glibc-2.19'
do_clean

# glibc can't be built on case-insensitive filesystems (wow). We can work around this by using fsutil on
# the build directory (it turns out that only build artifacts clash). This must be done while the
# directory is empty
fsutil file setCaseSensitiveInfo "$build_path" enable

do_configure \
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
    libc_cv_rtlddir=/lib \
    libc_cv_ld_no_whole_archive=yes

# --disable-sanity-checks \

PATH="$host_tools/bin:$PATH"
pwd
# There seems to be race conditions for parallel builds =( so no -j
do_make
do_make -j$(nproc) \
     install_root="$sysroot" \
     INSTALL="$(which install)" \
     install

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
#find "$host_tools" -name '*.la' -delete
