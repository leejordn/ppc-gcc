#! /usr/bin/env bash

# Source this script before running any configur scripts. If you don't, configure screws up a lot of
# these paths, especially LD, and you'll get very cryptic errors.

# Assumes $host_tools/bin contains a working (stage-1) $target toolchain (e.g.
# powerpc-linux-gnu-gcc)

source common-defs.sh

activate ()
{
    if [[ -n ${_cross_env_active+x} ]]; then
        echo "Cross-compiling toolchain is active. Run `deactivate` first." >&2
        exit 1
    fi
    if [[ -n ${_host_env_active+x} ]]; then
        echo "Host toolchain is active. Run `deactivate` first." >&2
        exit 1
    fi

    export AR="$host_tools/bin/$target-ar"
    export AS="$host_tools/bin/$target-as"
    export CC="$host_tools/bin/$target-gcc"
    export CPP="$host_tools/bin/$target-cpp"
    export CXX="$host_tools/bin/$target-g++"
    export LD="$host_tools/bin/$target-ld"
    export NM="$host_tools/bin/$target-nm"
    export OBJCOPY="$host_tools/bin/$target-objcopy"
    export OBJDUMP="$host_tools/bin/$target-objdump"
    export RANLIB="$host_tools/bin/$target-ranlib"
    export READELF="$host_tools/bin/$target-readelf"
    export STRIP="$host_tools/bin/$target-strip"

    export _cross_env_old_path="$PATH"
    export _cross_env_old_ps1="$PS1"
    export PS1="\n(cross-env) $PS1"
    export PATH="$host_tools/bin:$PATH"

    export _cross_env_active="true"

    unset -f activate   # Don't let me activate twice for some reason
    hash -r 2>/dev/null # Force PATH changes to take place immmediately
}


deactivate ()
{

    unset AR
    unset AS
    unset CC
    unset CPP
    unset CXX
    unset LD
    unset NM
    unset OBJCOPY
    unset OBJDUMP
    unset RANLIB
    unset READELF
    unset STRIP

    export PATH="$_cross_env_old_path"
    export PS1="$_cross_env_old_ps1"
    unset _cross_env_old_ps1
    unset _cross_env_old_path
    unset _cross_env_active

    unset -f deactivate # Already deactivated - self destruct
    hash -r 2>/dev/null # Force PATH changes to take place immediately
}


activate
export -f deactivate
