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

source "$project_scripts/host-env.sh"

mkdir -p "$host_tools"
verify_ucrt64
select_source 'gettext-0.22'

do_clean
do_configure \
    --disable-shared \
    --enable-static \
    --prefix="$host_tools"

do_make -j$(nproc)
do_make -j$(nproc) install

# BURN ALL LIBTOOL ARCHIVES - they cause nothing but trouble! Overlinking, disrespecting
# --with-build-sysroot, and false positives that cause `ld` to freeze. Gentoo, Debian, Arch, Fedora,
# and many more Linux distros actually delete them aggressively on system start. This enables our
# $host_tools directory (and cross toolchain sysroot) to be completely portable / relocatable
find "$host_tools" -name '*.la' -delete


# am_cv_lib_iconv=no
# gl_cv_func_working_iconv=no
# am_cv_func_iconv=no
