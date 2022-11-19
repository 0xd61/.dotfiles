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

check_no_root() {
    if [ "$USER" == "root" ]
    then
        echo -e "${RED_TERMINAL_OUTPUT}Please run this as non-root${CLEAR}"
        exit 2
    fi
}

update() {
# NOTE(dgl): We keep the channel upgrade separate
#     echo -e "${GREEN_TERMINAL_OUTPUT}Updating channels${CLEAR}"
#     nix-channel --update
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
    if which home-manager > /dev/null; then
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
FLAKE="${1}" && [ ! -z "${FLAKE}" ] && shift
ARGS="${@}"

case "${COMMAND}" in
update)
    update
;;
system_build)
    [ -z "${FLAKE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No flake provided${CLEAR}"; usage; exit 1; }
    check_root
    build_system "${FLAKE}"
;;
system_upgrade)
    [ -z "${FLAKE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No flake provided${CLEAR}"; usage; exit 1; }
    check_root
    update
    build_system "${FLAKE}"
;;
user_build)
    [ -z "${FLAKE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No flake provided${CLEAR}"; usage; exit 1; }
    check_no_root
    build_user "${FLAKE}"
;;
user_upgrade)
    [ -z "${FLAKE}" ] && { echo -e "${RED_TERMINAL_OUTPUT}No flake provided${CLEAR}"; usage; exit 1; }
    check_no_root
    update
    build_user "${FLAKE}"
;;
*)
    usage
;;
esac
