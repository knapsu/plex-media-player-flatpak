#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR=${PWD}

BUILD_DIR="app/build"
REPO_DIR="repo"

if [[ -z "${PLEX_TAG}" ]]; then
  echo "Not a release. Skipping upload."
  exit
fi

if [ ! -d "${BUILD_DIR}" ]; then
  echo "Build directory not found"
  exit
fi

echo "Import PGP key for signing"
gpg --import keys/pgp-flatpak.asc

echo "Add package to repository"
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
flatpak build-export --subject="${FLATPAK_SUBJECT}" --gpg-sign=45971D9CA4780454 --update-appstream "${REPO_DIR}" "${BUILD_DIR}" "${FLATPAK_BRANCH}"

flatpak repo --branches repo
# flatpak repo --commits=app/tv.plex.PlexMediaPlayer/x86_64/${FLATPAK_BRANCH} repo
