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

p() {
  printf "%-9s: %-40s\n" "$1" "$2"
}
ensure_dir() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    p "Executing" "mkdir -p $dir"
    mkdir -p "$dir"
  fi
}
ensure_file() {
  local file="$1"
  [[ -f "$file" ]] && return 0
  return "$?"
}

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
    local toc="setup.toc"
    local pkgmeta="setup.yml"
    local pkgmeta_path="./dev/${pkgmeta}"

    ensure_dir "$BUILD_DIR"
    cp "${pkgmeta_path}" "_${pkgmeta}" || {
      echo "Missing: ${pkgmeta_path}"
      return 1
    }
    ensure_file "./_${pkgmeta}" || {
      p "Missing: $file"
      return 1
    }
    cp ./dev/${toc} _${toc}

    local args="-duz -r ${BUILD_DIR} -m _${pkgmeta}"
    local cmd="${RELEASE_SCRIPT} ${args}"
    echo "Executing: ${cmd}"
    eval "${cmd}" && echo "Execution Complete: ${cmd}" || {
      echo "Run failed."
      return 1
    }
    echo "Cleaning up..." && {
      rm _${pkgmeta}
      rm _${toc}
    }
}

_Release "${REL_CONFIG}"
