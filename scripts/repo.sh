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

SCP_USER=${SCP_USER:=knapsu}
SCP_SERVER=${SCP_SERVER:?Missing SCP_SERVER variable}
SCP_PATH=${SCP_PATH:?Missing SCP_PATH variable}

if [[ "${REPO_DOWNLOAD}" == "true" ]]; then
  echo "Download repository"
  rsync --archive --delete --exclude '*.lock' --stats ${SCP_USER}@${SCP_SERVER}:"${SCP_PATH}/" "${REPO_DIR}/"
fi

if [[ "${REPO_UPLOAD}" == "true" ]]; then
  echo "Upload repository"
  rsync --archive --delete --exclude '*.lock' --stats "${REPO_DIR}/" ${SCP_USER}@${SCP_SERVER}:"${SCP_PATH}/"
fi
