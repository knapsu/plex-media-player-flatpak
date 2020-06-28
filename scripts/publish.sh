#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR=${PWD}

BUILD_DIR="app/build"

if [[ -z "${PLEX_TAG}" ]]; then
  echo "Not a release. Skipping upload."
  exit
fi

if [ ! -d "${BUILD_DIR}" ]; then
  echo "Nothing to upload"
  exit
fi

echo "Synchronizing Flatpak repository"
UPLOAD_USER=${UPLOAD_USER:?Missing user variable}
UPLOAD_SERVER=${UPLOAD_SERVER:?Missing server variable}
UPLOAD_PATH=${UPLOAD_PATH:?Missing path variable}

echo "Download repo"
rsync --archive --delete --exclude '*.lock' --stats -e "ssh -i keys/id_rsa" ${UPLOAD_USER}@${UPLOAD_SERVER}:${UPLOAD_PATH} repo/

echo "Add package to repo"
FLATPAK_SUBJECT="Plex Media Player"
FLATPAK_BRANCH="main"

if [[ -n "${PLEX_TAG}" ]]; then
  # Display version number in commit message
  if [[ "${PLEX_TAG}" =~ ^v([0-9\.]+)\.([0-9]+)(-(.*))? ]]; then
    FLATPAK_SUBJECT="Plex Media Player ${PLEX_TAG:1}"
  else
    FLATPAK_SUBJECT="Plex Media Player ${PLEX_TAG}"
  fi
  # Publish to release branch
  FLATPAK_BRANCH="release"
fi

echo "commit: ${FLATPAK_SUBJECT}"
echo "branch: ${FLATPAK_BRANCH}"

# Sign commit
flatpak build-export --subject="${FLATPAK_SUBJECT}" --gpg-sign=45971D9CA4780454 --update-appstream "repo" "${BUILD_DIR}" "${FLATPAK_BRANCH}"

flatpak repo --branches repo
# flatpak repo --commits=app/tv.plex.PlexMediaPlayer/x86_64/${FLATPAK_BRANCH} repo

echo "Upload repo"
rsync --archive --delete --exclude '*.lock' --stats -e "ssh -i keys/id_rsa" repo/ ${UPLOAD_USER}@${UPLOAD_SERVER}:${UPLOAD_PATH}/
