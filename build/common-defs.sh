# These should be the same across the entire project

# Setting --prefix= or --prefix="" DOESN'T WORK in MSYS. So I have to structure my own toolchain
# directory in a dumb way to get around MSYS's pseudo-Unix path deduction behavior
# compiler_prefix="/./" # This is passed to --prefix for GCC and Binutils

target="powerpc-linux-gnu"
toolchain="$(realpath "$PWD/../toolchain")"
sysroot_prefix="/$target/sysroot" # This is passed to --sysroot
sysroot="${toolchain}${sysroot_prefix}" # This is the actual full path to the target sysroot
host_tools="$PWD/host-tools"
