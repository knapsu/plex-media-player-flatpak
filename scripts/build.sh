#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR="${PWD}"

git config --global advice.detachedHead false

# Define build variables
DATE=$(date -u +'%Y%m%d')

if [[ "${TRAVIS_EVENT_TYPE}" == "cron" ]]; then
  echo "Scheduled build"
elif [[ "${TRAVIS_EVENT_TYPE}" == "api" ]]; then
  echo "Triggered build"
else
  echo "Standard build"
fi

rm -rf app
mkdir -p app

if [[ -n "${PLEX_TAG}" ]]; then
  echo "PLEX_TAG environment variable found. Using ${PLEX_TAG} sources"
  cat tv.plex.PlexMediaPlayer.json | jq -r ".modules[1].sources[0].tag=\"${PLEX_TAG}\"" > app/tv.plex.PlexMediaPlayer.json
fi

# Flatpak manifest file contains source code information
if [[ -n "${PLEX_TAG}" ]]; then
  echo "Adjusting Flatpak manifest file"
  cat tv.plex.PlexMediaPlayer.json | jq -r ".modules[1].sources[0].tag=\"${PLEX_TAG}\"" > app/tv.plex.PlexMediaPlayer.json
else
  cp tv.plex.PlexMediaPlayer.json app/tv.plex.PlexMediaPlayer.json
fi

# AppStream metadata file contains release information
if [[ -n "${PLEX_TAG}" ]]; then
  echo "Adjusting AppStream metadata file"
  cp tv.plex.PlexMediaPlayer.appdata.xml app/tv.plex.PlexMediaPlayer.appdata.xml
  # curl -f -s -S -o - https://api.github.com/repos/plexinc/plex-media-player/releases | jq -c ".[] | {tag_name, published_at}" | sed -E 's/\{"tag_name":"(.+)","published_at":"(.+)T.+"\}/<release version="\1" date="\2"\/>/'
  if [[ "${PLEX_TAG}" =~ ^v([0-9\.]+)\.([0-9]+)(-(.*))? ]]; then
    VERSION="${PLEX_TAG:1}"
  else
    VERSION="${PLEX_TAG}"
  fi
  sed -z -E "s|<releases>.*</releases>|<releases><release version=\"${VERSION}\"/></releases>|" -i app/tv.plex.PlexMediaPlayer.appdata.xml
else
  echo "Stripping release information from metadata file"
  cp tv.plex.PlexMediaPlayer.appdata.xml app/tv.plex.PlexMediaPlayer.appdata.xml
  sed -z -E "s|<releases>.*</releases>||" -i app/tv.plex.PlexMediaPlayer.appdata.xml
fi

# Desktop file
cp tv.plex.PlexMediaPlayer.desktop app/tv.plex.PlexMediaPlayer.desktop

# Create Flatpak
cd app
cat tv.plex.PlexMediaPlayer.json
flatpak-builder --state-dir=../flatpak-builder --delete-build-dirs build tv.plex.PlexMediaPlayer.json
