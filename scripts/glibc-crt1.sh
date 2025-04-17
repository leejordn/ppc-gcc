#! /usr/bin/env bash

set -e
#set -u
#set -x # Uncomment to debug

source_name='glibc-2.19'
source scripts/common.sh
source cross-env.sh

verify_ucrt64

# glibc-headers should have been run directly before this, so we just need to get the variable
# definitions (yes, it's not obvious from the function name in this context)
parse_cli "$@"

if [[ ! -d "$build_dir" ]]; then
    echo "ERROR: Run glibc-headers.sh first." >&2
    exit 1
fi

temp="$build_dir/temp"
mkdir -p $temp

# For static builds, we don't get a lib-names.h at the moment, so stub one out
# MAY NOT NEED THIS - I don't THINK I'm making a static build here? I'll test later
echo '#include LIBCDN_SO ""' > "$temp/lib-names.h"

libdir="$sysroot/usr/lib"
rtldir="$sysroot/lib"
mkdir -p "$libdir" "$rtldir"

make -j$(nproc) -C "$build_dir" csu/subdir_lib
cp "$build_dir/csu/crt1.o" \
   "$build_dir/csu/crti.o" \
   "$build_dir/csu/crtn.o" \
   "$libdir"

# Create an empty libc.so that satisfies the linker when something tries to -lc during libgcc or
# stage 2 GCC build
$CC ${abi:-} -nostdlib -nostartfiles -shared -x c -o "$libdir/libc.so" /dev/null

# Usually generated during the full build, but not while bootstrapping. Stage 2 glibc will expect
# this to exist, so just make it now.
gnu_header_dir="$sysroot/include/gnu"
mkdir -p "$gnu_header_dir" && touch "$gnu_header_dir/stubs.h"

rm -rf "$temp"
