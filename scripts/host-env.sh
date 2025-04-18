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

    # If this isn't done, configure tries to use native windows paths, which makes itself panic
    export AR="$(which ar)"
    export AS="$(which as)"
    export CC="$(which gcc)"
    export CPP="$(which cpp)"
    export CXX="$(which g++)"
    export LD="$(which ld)"
    export NM="$(which nm)"
    export OBJCOPY="$(which objcopy)"
    export OBJDUMP="$(which objdump)"
    export RANLIB="$(which ranlib)"
    export READELF="$(which readelf)"
    export STRIP="$(which strip)"
    export WINDRES="$(which windres)"

    export AR_FOR_BUILD="$AR"
    export AS_FOR_BUILD="$AS"
    export CC_FOR_BUILD="$CC"
    export CPP_FOR_BUILD="$CPP"
    export CPP_FOR_BUILD="$CPP"
    export CXX_FOR_BUILD="$CXX"
    export LD_FOR_BUILD="$LD"
    export NM_FOR_BUILD="$NM"
    export OBJCOPY_FOR_BUILD="$OBJCOPY"
    export OBJDUMP_FOR_BUILD="$OBJDUMP"
    export RANLIB_FOR_BUILD="$RANLIB"
    export READELF_FOR_BUILD="$READELF"
    export STRIP_FOR_BUILD="$STRIP"
    export WINDRES_FOR_PATH="$WINDRES"

    export AR_FOR_HOST="$AR"
    export AS_FOR_HOST="$AS"
    export CC_FOR_HOST="$CC"
    export CPP_FOR_HOST="$CPP"
    export CXX_FOR_HOST="$CXX"
    export LD_FOR_HOST="$LD"
    export NM_FOR_HOST="$NM"
    export OBJCOPY_FOR_HOST="$OBJCOPY"
    export OBJDUMP_FOR_HOST="$OBJDUMP"
    export RANLIB_FOR_HOST="$RANLIB"
    export READELF_FOR_HOST="$READELF"
    export STRIP_FOR_HOST="$STRIP"
    export WINDRES_FOR_HOST="$WINDRES"

    export AR_FOR_TARGET="$toolchain/bin/$target-ar"
    export AS_FOR_TARGET="$toolchain/bin/$target-as"
    export CC_FOR_TARGET="$toolchain/bin/$target-gcc"
    export CPP_FOR_TARGET="$toolchain/bin/$target-cpp"
    export CXX_FOR_TARGET="$toolchain/bin/$target-g++"
    export LD_FOR_TARGET="$toolchain/bin/$target-ld"
    export NM_FOR_TARGET="$toolchain/bin/$target-nm"
    export OBJCOPY_FOR_TARGET="$toolchain/bin/$target-objcopy"
    export OBJDUMP_FOR_TARGET="$toolchain/bin/$target-objdump"
    export RANLIB_FOR_TARGET="$toolchain/bin/$target-ranlib"
    export READELF_FOR_TARGET="$toolchain/bin/$target-readelf"
    export STRIP_FOR_TARGET="$toolchain/bin/$target-strip"

    if [[ -n "${PS1+x}" ]]; then
        export _host_env_old_ps1="${PS1}"
        export PS1="\n(host-env) $PS1"
    fi

    export _host_env_old_path="$PATH"
    export PATH="$host_tools/bin:$toolchain/bin:$PATH"
    export _host_env_active="true"
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
    unset LD
    unset NM
    unset OBJCOPY
    unset OBJDUMP
    unset RANLIB
    unset READELF
    unset STRIP

    unset AR_FOR_BUILD
    unset AS_FOR_BUILD
    unset CC_FOR_BUILD
    unset CPP_FOR_BUILD
    unset CXX_FOR_BUILD
    unset LD_FOR_BUILD
    unset NM_FOR_BUILD
    unset OBJCOPY_FOR_BUILD
    unset OBJDUMP_FOR_BUILD
    unset RANLIB_FOR_BUILD
    unset READELF_FOR_BUILD
    unset STRIP_FOR_BUILD

    unset AR_FOR_HOST
    unset AS_FOR_HOST
    unset CC_FOR_HOST
    unset CPP_FOR_HOST
    unset CXX_FOR_HOST
    unset LD_FOR_HOST
    unset NM_FOR_HOST
    unset OBJCOPY_FOR_HOST
    unset OBJDUMP_FOR_HOST
    unset RANLIB_FOR_HOST
    unset READELF_FOR_HOST
    unset STRIP_FOR_HOST

    unset AR_FOR_TARGET
    unset AS_FOR_TARGET
    unset CC_FOR_TARGET
    unset CPP_FOR_TARGET
    unset CXX_FOR_TARGET
    unset LD_FOR_TARGET
    unset NM_FOR_TARGET
    unset OBJCOPY_FOR_TARGET
    unset OBJDUMP_FOR_TARGET
    unset RANLIB_FOR_TARGET
    unset READELF_FOR_TARGET
    unset STRIP_FOR_TARGET

    if [[ -n ${_host_env_old_ps1+x} ]]; then
        export PS1="$_host_env_old_ps1"
        unset _host_env_old_ps1
    fi

    export PATH="$_host_env_old_path"
    unset _host_env_old_path
    unset _host_env_active
    unset -f deactivate # Already deactivated - self destruct
    hash -r 2>/dev/null # Force PATH changes to take place immediately
}

activate
export -f deactivate
