#!/usr/bin/env bash

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
exec 4>&1; export BASH_XTRACEFD=4; set -x
# make errors fatal
set -e
# complain about unset env variables
set -u

if [ -z "$AUTOBUILD" ] ; then 
    exit 1
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    autobuild="$(cygpath -u $AUTOBUILD)"
else
    autobuild="$AUTOBUILD"
fi

top="$(pwd)"
stage="$(pwd)/stage"
stage_release="$stage/lib/release"

mkdir -p $stage

# Load autobuild provided shell functions and variables
source_environment_tempfile="$stage/source_environment.sh"
"$autobuild" source_environment > "$source_environment_tempfile"
. "$source_environment_tempfile"

NVAPI_VERSION="R450"
NVAPI_ARCHIVE="$NVAPI_VERSION-developer.zip"
NVAPI_SOURCE_DIR="$NVAPI_VERSION-developer"

build=${AUTOBUILD_BUILD_ID:=0}

echo "${NVAPI_VERSION}.${build}" > "${stage}/VERSION.txt"

cp "nvapi/$NVAPI_ARCHIVE" .

unzip "$NVAPI_ARCHIVE"

# Create the staging folders
mkdir -p $stage/{LICENSES,lib/release,include/nvapi}

pushd "$NVAPI_SOURCE_DIR"
    case "$AUTOBUILD_PLATFORM" in
        "windows")
            cp "x86/nvapi.lib" "$stage_release"
        ;;
        "windows64")
            cp "amd64/nvapi64.lib" "$stage_release"
        ;;
    esac

    # Copy the headers
	cp -a *.h "$stage/include/nvapi"
popd

# Copy License
cp -a nvapi.txt $stage/LICENSES/

