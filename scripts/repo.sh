#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR=${PWD}

if [ $# -eq 0 ]; then
  echo "Missing script arguments" >&2
  exit 1
fi
OPTIONS=$(getopt -o '' -l download,upload -- "$@")
if [ $? -ne 0 ] ; then
  echo "Invalid script arguments" >&2
  exit 2
fi
eval set -- "$OPTIONS"

while true; do
  case "$1" in
    (--download)
      REPO_DOWNLOAD="true"
      shift;;
    (--upload)
      REPO_UPLOAD="true"
      shift;;
    (--)
      shift; break;;
    (*)
      break;;
  esac
done

REPO_DIR="repo"

UPLOAD_USER=${UPLOAD_USER:?Missing user variable}
UPLOAD_SERVER=${UPLOAD_SERVER:?Missing server variable}
UPLOAD_PATH=${UPLOAD_PATH:?Missing path variable}

if [[ "${REPO_DOWNLOAD}" == "true" ]]; then
  echo "Download repository"
  rsync --archive --delete --exclude '*.lock' --stats ${UPLOAD_USER}@${UPLOAD_SERVER}:"${UPLOAD_PATH}/" "${REPO_DIR}/"
fi

if [[ "${REPO_UPLOAD}" == "true" ]]; then
  echo "Upload repository"
  rsync --archive --delete --exclude '*.lock' --stats "${REPO_DIR}/" ${UPLOAD_USER}@${UPLOAD_SERVER}:"${UPLOAD_PATH}/"
fi
