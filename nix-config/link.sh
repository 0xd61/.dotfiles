#!/bin/sh

SCRIPT="$(realpath $0)"
BASEDIR=$(dirname "$SCRIPT")

ln -s $BASEDIR/configuration.nix /etc/nixos/configuration.nix
ln -s $BASEDIR/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
