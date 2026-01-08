#!/usr/bin/env zsh

ADDON_NAME=Gears
# REL_CONFIG Must match package-as in pull-extlib.toc
# package-as: dev/pull-extlib
REL_CONFIG=dev/pull-extlib.yaml
BUILD_DIR=./.release
SCRIPT_DIR=./dev
RELEASE_SCRIPT=${SCRIPT_DIR}/release.sh
PACKAGE_NAME=Pull-Ext-Lib
EXT_LIB_DIR=ExtLib

# ./dev/release.sh -duz -m ./dev/pull-ext-lib.toc
# Options:
# -d  Skip uploading.
# -u  Use Unix line-endings.
# -z  Skip zip file creation.
# -r  releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
# -m  pkgmeta.yaml  Set the pkgmeta file to use.
_Release() {
    if [[ "$1" = "" ]]; then
        echo "Usage: ./release <pkgmeta-file.yml>"
        return 0
    fi
    local pkgmeta="$1"
    local args="-duz -r ${BUILD_DIR} -m ${pkgmeta}"
    local cmd="${RELEASE_SCRIPT} ${args}"
    echo "Executing: ${cmd}"
    eval "${cmd}" && echo "Execution Complete: ${cmd}"
}

_Release "${REL_CONFIG}"
