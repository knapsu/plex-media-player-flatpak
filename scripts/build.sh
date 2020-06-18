#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "${SCRIPT}")
WORKDIR="${PWD}"

# Update releases in AppStream metadata
curl -f -s -S -o - https://api.github.com/repos/plexinc/plex-media-player/releases | jq -c ".[] | {tag_name, published_at}" | sed -E 's/\{"tag_name":"(.+)","published_at":"(.+)T.+"\}/<release version="\1" date="\2"\/>/'
