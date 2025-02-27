#!/bin/bash

cd "$(dirname "$0")" 

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e
# complain about unset env variables
set -u

# Check autobuild is around or fail
if [ -z "$AUTOBUILD" ] ; then 
    fail0
fi
if [ "$OSTYPE" = "cygwin" ] ; then
    autobuild="$(cygpath -u $AUTOBUILD)"
else
    autobuild="$AUTOBUILD"
fi

# Load autobuild provided shell functions and variables
set +x
eval "$("$autobuild" source_environment)"
set -x

# set LL_BUILD and friends ... moot since we're not building anything
#set_build_variables convenience Release

NVAPI_ROOT_NAME="nvapi"

top="$(pwd)"
stage="$(pwd)/stage"
mkdir -p "$stage"

pushd "$NVAPI_ROOT_NAME"
    mkdir -p "$stage/include/nvapi"
    mkdir -p "$stage/LICENSES"
    mkdir -p "$stage/lib/release"

    case "$AUTOBUILD_PLATFORM" in

        windows*)
            cp "amd64/nvapi64.lib" "$stage/lib/release/nvapi.lib"

            cp *.h "$stage/include/nvapi/"
            cp *.c "$stage/include/nvapi/"

            cp "License.txt" "$stage/LICENSES/nvapi.txt"
        ;;
    esac
popd