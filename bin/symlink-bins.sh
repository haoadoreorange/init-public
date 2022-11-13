#!/bin/sh
set -eu

BIN="$(dirname "$(realpath $BASH_SOURCE)")"
ln -fs ../init-modules/link-configs.sh "$BIN"/link-configs
ln -fs ../init-modules/one-time-only/setup-home-cloud.sh "$BIN"/setup-home-cloud
ln -fs ../init-modules/update-pkgs.sh "$BIN"/update-pkgs
chmod +x "$BIN"/*
