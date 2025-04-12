#! /usr/bin/env bash

# Source this script before running any configur scripts. If you don't, configure screws up a lot of
# these paths, especially LD, and you'll get very cryptic errors.

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

    export AR="$host_tools/bin/$target-ar.exe"
    export AS="$host_tools/bin/$target-as.exe"
    export LD="$host_tools/bin/$target-ld.exe"
    export NM="$host_tools/bin/$target-nm.exe"
    export OBJCOPY="$host_tools/bin/$target-objcopy"
    export OBJDUMP="$host_tools/bin/$target-objdump"
    export RANLIB="$host_tools/bin/$target-ranlib.exe"
    export READELF="$host_tools/bin/$target-readelf.exe"
    export STRIP="$host_tools/bin/$target-strip.exe"

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
    unset LD
    unset AR
    unset AS
    unset LD
    unset NM
    unset OBJCOPY
    unset OBJDUMP
    unset RANLIB
    unset READELF
    unset STRIP

    unset AR_FOR_BUILD
    unset AS_FOR_BUILD
    unset LD_FOR_BUILD
    unset NM_FOR_BUILD
    unset OBJCOPY_FOR_BUILD
    unset OBJDUMP_FOR_BUILD
    unset RANLIB_FOR_BUILD
    unset READELF_FOR_BUILD
    unset STRIP_FOR_BUILD

    unset AR_FOR_HOST
    unset AS_FOR_HOST
    unset LD_FOR_HOST
    unset NM_FOR_HOST
    unset OBJCOPY_FOR_HOST
    unset OBJDUMP_FOR_HOST
    unset RANLIB_FOR_HOST
    unset READELF_FOR_HOST
    unset STRIP_FOR_HOST

    unset AR_FOR_TARGET
    unset AS_FOR_TARGET
    unset LD_FOR_TARGET
    unset NM_FOR_TARGET
    unset OBJCOPY_FOR_TARGET
    unset OBJDUMP_FOR_TARGET
    unset RANLIB_FOR_TARGET
    unset READELF_FOR_TARGET
    unset STRIP_FOR_TARGET

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
