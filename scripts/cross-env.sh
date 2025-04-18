#! /usr/bin/env bash

# Source this script before running any configur scripts. If you don't, configure screws up a lot of
# these paths, especially LD, and you'll get very cryptic errors.

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


activate ()
{
    if [[ -n ${_cross_env_active+x} ]]; then
        echo "Cross-compiling toolchain is active. Run "deactivate" first." >&2
        return 1
    fi
    if [[ -n ${_host_env_active+x} ]]; then
        echo "Host toolchain is active. Run "deactivate" first." >&2
        return 1
    fi

    export AR="$toolchain/bin/$target-ar"
    export AS="$toolchain/bin/$target-as"
    export CC="$toolchain/bin/$target-gcc"
    export CPP="$toolchain/bin/$target-cpp"
    export CXX="$toolchain/bin/$target-g++"
    export LD="$toolchain/bin/$target-ld"
    export NM="$toolchain/bin/$target-nm"
    export OBJCOPY="$toolchain/bin/$target-objcopy"
    export OBJDUMP="$toolchain/bin/$target-objdump"
    export RANLIB="$toolchain/bin/$target-ranlib"
    export READELF="$toolchain/bin/$target-readelf"
    export STRIP="$toolchain/bin/$target-strip"

    if [[ -n ${PS1+x} ]]; then
        export _cross_env_old_ps1="$PS1"
        export PS1="\n(cross-env) $PS1"
    fi

    export _cross_env_old_path="$PATH"
    export PATH="$toolchain/bin:$host_tools/bin:$PATH"

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
