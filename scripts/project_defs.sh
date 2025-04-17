#! /usr/bin/env bash

# Define the following variable(s) in your individual configure scripts, and source this file
# (before using any of the functions here)
# source_name=''

# Get the absolute path to the script and its parent
# Courtesy of https://stackoverflow.com/a/246128
script_parent=""
script_source=${BASH_SOURCE[0]}
while [ -L "$script_source" ]; do
    # resolve $script_source until the file is no longer a symlink
    script_parent=$( cd -P "$( dirname "$script_source" )" >/dev/null 2>&1 && pwd )
    script_source=$(readlink "$script_source")
    # if $script_source was a relative symlink, we need to resolve it relative to the path where the
    # symlink file was located
    [[ $script_source != /* ]] && script_source=$script_parent/$script_source
done
script_parent=$( cd -P "$( dirname "$script_source" )" >/dev/null 2>&1 && pwd )

ec_wrong_env=1
ec_invalid_source=2
ec_invalid_build_path=3
ec_configure_failed=4


# Variables that will be used heavily across the project
export project_root="$(realpath $script_parent/..)"
export project_builds="$project_root/build"
export project_sources="$project_root/sources"
export project_scripts="$script_parent"
export target="powerpc-linux-gnu"
export toolchain="$project_root/toolchain"
export sysroot_prefix="/$target/sysroot" # Use this as --sysroot in configure scripts
export sysroot="${toolchain}${sysroot_prefix}" # This is the actual full path to the target sysroot
export host_tools="$PWD/host-tools"


verify_ucrt64 ()
{
    if [[ "$(uname -o)" != 'Msys' ]] || [[ "$MSYSTEM" != 'UCRT64' ]]; then
        echo "Not in an MSYS2 UCRT64 shell. Exiting..." >&2
        return $ec_wrong_env
    fi
}


verify_msys ()
{
    if [[ "$(uname -o)" != 'Msys' ]] || [[ "$MSYSTEM" != 'MSYS' ]]; then
        echo "Not in an MSYS2 MSYS shell. Exiting..." >&2
        return $ec_wrong_env
    fi
}


verify_packages ()
{
    local uninstalled=()
    for package in "$@"; do
        if ! pacman -Q "$package" &>/dev/null; then
            uninstalled+=("$package")
        fi
    done
    if (( ${#uninstalled[@]} > 0 )); then
        echo >&2
        echo "❌ The following packages are required but not installed:" >&2
        for pkg in "${uninstalled[@]}"; do
            echo "  • $pkg" >&2
        done
        echo >&2
        return 1
    fi
}


select_source ()
{
    if [[ $# -gt 0 ]] && [[ -n "$1" ]]; then
        source_name="$1"
    else
        if [[ -n ${source_name+x} ]]; then
            echo "select_source requires a path argument or \$source_name to be defined" >&2
            return $ec_invalid_source
        fi
    fi
    export source_name
    export source_path="$project_sources/$source_name"
    export configure="$source_path/configure"
    export build_path="$project_builds/$source_name"
    if [[ ! -f "$configure" ]]; then
        echo "Expected file \"$configure\" to exist" >&2
        unset source_path
        unset configure
        unset build_path
        return $ec_invalid_source
    fi
}


do_clean ()
{
    if [[ -z ${build_path+x} ]]; then
        echo "Please use select_source first. Exiting..." >&2
        return $ec_invalid_source
    fi
    echo "Preparing directory \"$build_path\"..."
    rm -rf "$build_path"
    mkdir "$build_path"
}


do_configure () # ARGS: configure flags
{
    if [[ -z ${configure+x} ]]; then
        echo "Use source_select first. Exiting..." >&2
        return $ec_invalid_source
    fi
    pushd . &>/dev/null
    echo "Entering directory \"$build_path\"..."
    cd "$build_path"
    echo "Configuring \"$source_name\"..."
    # Using the relative path to configure because of pseudo-unix path issues:
    #   https://github.com/JuliaLang/julia/issues/13206#issuecomment-1799367162
    #   https://stackoverflow.com/questions/77414776/checking-size-of-mp-limb-t-0-and-configure-error-oops-mp-limb-t-doesnt/77435216#77435216
    "$(realpath --relative-to=. "$configure")" "$@"
    configure_ec="$?"
    if [[ $configure_ec -ne 0 ]]; then
        cat << EOF
--------------------------------------------------------------------------------
                                     ERROR                                     |
--------------------------------------------------------------------------------
                 CONFIGURE HAS FAILED WITH CODE $configure_ec                  |
--------------------------------------------------------------------------------
EOF
        return $ec_configure_failed
    fi
    printf "Returning to: "
    popd
}


# Pass options to this function just as you would to `make`
# Set make_path if you want to override the default ($build_path)
do_make () # ARGS: make flags
{
    local path="${make_path:-${build_path:-}}"
    if [[ -z "$path" ]]; then
        echo "Set make_path or use select_source first. Exiting..." >&2
        return $ec_invalid_source
    fi
    make -C "$path" "$@"
}
