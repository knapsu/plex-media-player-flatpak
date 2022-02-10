#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR=${PWD}

BUILD_DIR="app/build"
REPO_DIR="repo"

OPTIONS=$(getopt -o '' -l 'comment:' -- "$@")
if [ $? -ne 0 ] ; then
  echo "Invalid script arguments" >&2
  exit 2
fi
eval set -- "$OPTIONS"

while true; do
  case "$1" in
    (--comment)
      COMMENT="$2"
      shift 2;;
    (--)
      shift; break;;
    (*)
      break;;
  esac
done

if [[ -z "${PLEX_TAG}" ]]; then
  echo "Not a release. Skipping upload."
  exit
fi

if [ ! -d "${BUILD_DIR}" ]; then
  echo "Build directory not found"
  exit
fi

echo "Import PGP key for signing"
set +e
gpg --import keys/pgp-flatpak.asc
set -e

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

if [[ -n "${COMMENT}" ]]; then
  FLATPAK_SUBJECT=${COMMENT}
fi

echo "commit: ${FLATPAK_SUBJECT}"
echo "branch: ${FLATPAK_BRANCH}"

# Sign commit
flatpak build-export --subject="${FLATPAK_SUBJECT}" --gpg-sign=45971D9CA4780454 --update-appstream "${REPO_DIR}" "${BUILD_DIR}" "${FLATPAK_BRANCH}"

echo "Repository branches:"
flatpak repo --branches repo

echo "Repository commits:"
flatpak repo --commits=app/tv.plex.PlexMediaPlayer/x86_64/${FLATPAK_BRANCH} repo
