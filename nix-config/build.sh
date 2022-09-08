#!/bin/sh -e

export GREEN_TERMINAL_OUTPUT='\033[1;32m'
export RED_TERMINAL_OUTPUT='\033[1;31m'
export CLEAR='\033[0m'

if [ "$USER" != "root" ]
then
    echo -e "${RED_TERMINAL_OUTPUT}Please run this as root or with sudo${CLEAR}"
    exit 2
fi

update() {
    echo -e "${GREEN_TERMINAL_OUTPUT}Updating flakes${CLEAR}"
    nix flake update
}

build() {
    local FLAKE="${1}"
    echo -e "${GREEN_TERMINAL_OUTPUT}Building system for ${FLAKE}${CLEAR}"
    nixos-rebuild switch --flake "./#${FLAKE}"
}

MACHINE="${1}"
[ -z "${MACHINE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No machine provided${CLEAR}"; exit 1; }

shift
COMMAND="${1}"

case "${COMMAND}" in
build)
    build
;;
update)
    update
;;
upgrade)
    update
    build "${MACHINE}"
;;
*)
    build "${MACHINE}"
;;
esac
