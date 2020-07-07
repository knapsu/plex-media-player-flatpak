# Plex Media Player - Linux Flatpak

[![Travis Build Status](https://travis-ci.org/knapsu/plex-media-player-flatpak.svg?branch=master)](https://travis-ci.org/knapsu/plex-media-player-flatpak)

## Introduction

This repository automates building Linux Flatpak packages for Plex Media Player application.

Packages can be downloaded from https://knapsu.eu/plex/ site.

## Plex Media Player

Plex is a client-server software that makes it easy to watch different kinds of digital media on all kinds of devices, including living room TV, computer, tablet and even phone.
Plex Media Player is the computer desktop client that connects to Plex Media Server system where your movies and photos are stored.

For more information about Plex please visit https://www.plex.tv/ site.

If having questions or looking for help please visit [Plex Forums](https://forums.plex.tv/).

## Flatpak

Flatpak is a next-generation technology for building and distributing desktop applications on Linux.

For more information about Flatpak please visit https://flatpak.org/ site.

## Source code

Packages are build from official Plex Media Player source code without any modifications. Plex source code repository is available on GitHub.

https://github.com/plexinc/plex-media-player

## Docker

Docker was used to prepare a fully functional build environment image that contains everything what is needed to compile Plex Media Player. This image is used by continuous integration system (Travis CI) to start the package build process.

Docker images:
- [knapsu/plex-media-player-flatpak](https://hub.docker.com/r/knapsu/plex-media-player-flatpak/)

## Travis

Travis CI is responsible for doing the actual build. It initializes the build environment, compiles the application, assembles the package and publishes it. Travis build history is fully transparent and publicly available.

https://travis-ci.org/knapsu/plex-media-player-flatpak

## License

This project is released under [GNU General Public License](https://opensource.org/licenses/GPL-3.0).

Please note that Plex Media Player sources are available under its own license.

## Donations

If you like my work and would like me to continue maintaining it please [buy me a pizza](https://www.paypal.me/knapsu).
