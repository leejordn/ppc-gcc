#! /usr/bin/env bash
# Extract the Linux kernel headers needed to compile stage 1 glibc.

# WARNING: This will probably fail in MSYS2 UCRT64 - run this in MSYS2 MSYS. It is the most
# POSIX-compliant environment

set -e
set -u
#set -x # Uncomment to debug
set -o pipefail

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

# Linux expects in almost every make target that you are running it on Linux. I've tried all MSYS2
# configurations, but it has only worked without error in WSL.
verify_linux
use_host_env

select_source 'linux-6.14.2'
do_clean
pushd . &>/dev/null
cd "$build_path"
# Not the order things are usually done in with `make`, but this is what the linux docs say
make -C "$source_path" -j$(nproc)\
     O="$build_path/" \
     ARCH=powerpc \
     INSTALL_HDR_PATH="$sysroot/usr" \
     headers_install

if [[ $? -ne 0 ]]; then
    cat << EOF >&2
--------------------------------------------------------------------------------
  FAILED TO INSTALL KERNEL HEADERS
--------------------------------------------------------------------------------
EOF
fi
popd

# Something like this after?
# find linux-build/linux-2.6.27.18-headers -type f -name '.install' -o -name '*.cmd' -delete
