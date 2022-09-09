#!/bin/sh -e

export GREEN_TERMINAL_OUTPUT='\033[1;32m'
export RED_TERMINAL_OUTPUT='\033[1;31m'
export CLEAR='\033[0m'

check_root() {
    if [ "$USER" != "root" ]
    then
        echo -e "${RED_TERMINAL_OUTPUT}Please run this as root or with sudo${CLEAR}"
        exit 2
    fi
}

update() {
    echo -e "${GREEN_TERMINAL_OUTPUT}Updating channels${CLEAR}"
    nix-channel --update
    echo -e "${GREEN_TERMINAL_OUTPUT}Updating flakes${CLEAR}"
    nix flake update
}

build_system() {
    local FLAKE="${1}"
    echo -e "${GREEN_TERMINAL_OUTPUT}Building system for ${FLAKE}${CLEAR}"
    nixos-rebuild switch --flake "./#${FLAKE}"
}

build_home() {
    local FLAKE="${1}"
    echo -e "${GREEN_TERMINAL_OUTPUT}Building system for ${FLAKE}${CLEAR}"
    if which home-manager > /dev/null; then
        home-manager switch --impure --flake "./#${FLAKE}"
    else
        nix build --impure --no-link ./\#homeConfigurations.${FLAKE}.activationPackage
        "$(nix path-info \#homeConfigurations.${FLAKE}.activationPackage)"/activate
    fi
}

FLAKE="${1}"
[ -z "${FLAKE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No flake provided${CLEAR}"; exit 1; }

shift
COMMAND="${1}"

case "${COMMAND}" in
build_system)
    check_root
    build_system
;;
update_system)
    update
;;
upgrade_system)
    check_root
    update
    build_system "${FLAKE}"
;;
build_home)
    build_home "${FLAKE}"
;;
update_home)
    update
;;
upgrade_home)
    update
    build_home "${FLAKE}"
;;
*)
    build_home "${FLAKE}"
;;
esac
