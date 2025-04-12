# These should be the same across the entire project
target="powerpc-linux-gnu"
toolchain="$(realpath "$PWD/../toolchain")"
sysroot_prefix="/$target/sysroot"
sysroot="$toolchain$sysroot_prefix"
host_tools="$PWD/host-tools"
