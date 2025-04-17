#! /usr/bin/env bash
# Extract the Linux kernel headers needed to compile stage 1 glibc.

# WARNING: This will probably fail in MSYS2 UCRT64 - run this in MSYS2 MSYS. It is the most
# POSIX-compliant environment

set -e
set -u
set -o pipefail

verify_msys

release_version=2.6.27.18
source_name="linux-$release_version"
source_dir="../sources/$source_name"
output_dir="${source_name}-headers"

rm -rf "$output_dir"
mkdir -p "$output_dir"

make -j$(nproc) -C "$source_dir" O="$PWD/" ARCH=powerpc INSTALL_HDR_PATH="$output_dir" headers_install

# make headers_check \
#      -j$(nproc) \
#      -C "$source_dir" \
#      ARCH=powerpc \

# make headers_install \
#      -j$(nproc) \
#      -C "$source_dir" \
#      ARCH=powerpc \
#      INSTALL_HDR_PATH="$output_dir"

# Something like this after?
# find linux-build/linux-2.6.27.18-headers -type f -name '.install' -o -name '*.cmd' -delete
