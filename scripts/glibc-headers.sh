#! /usr/bin/env bash

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  IMPORTANT:
#    "patches/glibc-2.19-headers.patch" need to be applied before this script will work:
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


verify_msys
use_cross_env

# Linaro stuff
export AUTOCONF=no
export BUILD_CC=gcc

#export BUILD_CPPFLAGS=""
#export BUILD_CFLAGS=""

# Linaro does this but never defines the variables?
# libc_cv_slibdir=$libc_cv_slibdir
# libc_cv_rtlddir=$libc_cv_rtlddir

select_source 'glibc-2.19'

# glibc can't be built on case-insensitive filesystems (wow). We can work around this by using fsutil on
# the build directory (it turns out that only build artifacts clash). This must be done while the
# directory is empty
# fsutil file setCaseSensitiveInfo "$build_path" enable

# glibc can't be built with GNU make versions about 2.43 because of a regression in the way job
# pipelines work. So if the build fails, this is very pertinent information
make --version | head -n1

do_clean
do_configure \
    --build="x86_64-w64-mingw32" \
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
    --with-headers="$sysroot/usr/include" \
    --with-tls \
    --without-cvs \
    --without-gd \
    --without-selinux \
    libc_cv_visibility_attribute=yes \
    libc_cv_broken_visibility_attribute=no \
    libc_cv_forced_unwind=yes \
    libc_cv_ld_no_whole_archive=yes

do_make -j$(nproc) \
        install-bootstrap-headers=yes \
        install_root="$sysroot" \
        INSTALL="$(which install)" \
        install-headers

mv "$build_path" "stage-1-${build_path}"
