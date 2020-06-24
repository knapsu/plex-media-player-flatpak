#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR=${PWD}

if [[ -z "${PLEX_TAG}" ]]; then
  echo "Not a release. Skipping upload."
  exit
fi

if [ ! -d app/repo ]; then
  echo "Nothing to upload"
  exit
fi

echo "Synchronizing Flatpak repository"
UPLOAD_USER=${UPLOAD_USER:?Missing user variable}
UPLOAD_SERVER=${UPLOAD_SERVER:?Missing server variable}
UPLOAD_PATH=${UPLOAD_PATH:?Missing path variable}

echo "Download repo"
rsync --archive --delete --exclude '*.lock' --stats ${UPLOAD_USER}@${UPLOAD_SERVER}:${UPLOAD_PATH} repo/

echo "Add package to repo"
flatpak build-export repo app/build

echo "Upload repo"
rsync --archive --delete --exclude '*.lock' --stats repo/ ${UPLOAD_USER}@${UPLOAD_SERVER}:${UPLOAD_PATH}/
