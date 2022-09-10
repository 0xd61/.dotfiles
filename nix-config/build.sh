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

build_user() {
    local FLAKE="${1}"
    echo -e "${GREEN_TERMINAL_OUTPUT}Building system for ${FLAKE}${CLEAR}"
    if which home-manager 2>&1 /dev/null; then
        home-manager switch --impure --flake "./#${FLAKE}"
    else
        nix build --impure --no-link "./\#homeConfigurations.${FLAKE}.activationPackage"
        "$(nix path-info --impure ./\#homeConfigurations.${FLAKE}.activationPackage)/activate"
    fi
}

usage() {
    echo
    echo "Usage: build.sh [COMMAND] [FLAKE]"
    echo
    echo "    Install a system or home nix configuration provided by flakes."
    echo
    echo "      COMMAND :"
    echo "          build_system:   installing the specified nixos system"
    echo "          build_user:     installing the specified user config"
    echo "          update_system:  updating the system channels and the flake"
    echo "          update_user:    updating the user channels and the flake"
    echo "          upgrade_system: updating the system channels and the flake and installing the updated system packages"
    echo "          upgrade_user:   updating the user channels and the flake and installing the updated user packages"
    echo
    echo "    Example:"
    echo
    echo "        $ ./build.sh build_system home"
    echo
}

COMMAND="${1}"
shift
[ -z "${FLAKE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No flake provided${CLEAR}"; usage; exit 1; }
FLAKE="${1}"
shift
ARGS="${@}"

case "${COMMAND}" in
build_system)
    check_root
    build_system "${FLAKE}"
;;
update_system)
    update
;;
upgrade_system)
    check_root
    update
    build_system "${FLAKE}"
;;
build_user)
    build_user "${FLAKE}"
;;
update_user)
    update
;;
upgrade_user)
    update
    build_user "${FLAKE}"
;;
*)
    usage
;;
esac
