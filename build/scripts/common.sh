#! /usr/bin/env bash

# Define the following variable(s) in your individual configure scripts, and source this file
# (before using any of the functions here)
# source_name=''

source common-defs.sh

ec_wrong_env=1
ec_invalid_source=2
ec_invalid_build_dir=3
ec_configure_failed=4


usage ()
{
    cat << EOF

HELP
    Usage: $0 [source_directory_name]

    Create a build directory called source_directory_name ($source_name by
    default) and automatically configure it with the correct settings.

EOF
    exit 0
}


verify_ucrt64 ()
{
    if [[ "$(uname -o)" != 'Msys' ]] || [[ "$MSYSTEM" != 'UCRT64' ]]; then
        echo "Not in a UCRT64 shell. Exiting..." >&2
        exit $ec_wrong_env
    fi
}


# Call like this in the top level of your script: parse_cli "$@"
parse_cli ()
{
    while getopts "" "opt" &>/dev/null; do
        case "$opt" in
            *) usage ;;
        esac
    done
    if [[ $# -gt 0 ]] && [[ -n "$1" ]]; then
        source_name="$1"
    fi
    source_dir="$(realpath ../sources/$source_name)"
    configure="$source_dir/configure"
    build_dir="$(realpath "./$source_name")"
    if [[ ! -f "$configure" ]]; then
        echo "Expected file \"$configure\" to exist" >&2
        exit $ec_invalid_source
    fi
}


prepare_build_dir ()
{
    echo "Preparing directory \"$build_dir\"..."
    rm -rf "$build_dir"
    mkdir "$build_dir"
}


run_configure () # ARGS: configure_flags
{
    pushd . &>/dev/null
    echo "Entering directory \"$build_dir\"..."
    cd "$build_dir"
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
        exit $ec_configure_failed
    fi
    printf "Returning to: "
    popd
}


prepare_for_build () # ARGS: configure_flags
{
    verify_ucrt64
    prepare_build_dir
    run_configure $*
}
