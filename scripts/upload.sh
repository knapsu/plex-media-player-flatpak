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

echo "Synchronizing repository data with rsync"
UPLOAD_USER=${UPLOAD_USER:?Missing upload user variable}
UPLOAD_SERVER=${UPLOAD_SERVER:?Missing upload server variable}
# Decrypt SSH key on Travis CI
if [[ "${TRAVIS}" == "true" ]]; then
  openssl aes-256-cbc -K $encrypted_f217180e22ee_key -iv $encrypted_f217180e22ee_iv -in keys/id_rsa.enc -out keys/id_rsa -d
  chmod go-rwx keys/id_rsa
fi

rsync --archive --stats --exclude '*.lock' app/repo/ ${UPLOAD_USER}@${UPLOAD_SERVER}:${UPLOAD_PATH}
