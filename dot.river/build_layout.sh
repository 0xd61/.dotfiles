#!/bin/bash

set -e

wayland-scanner private-code < /usr/share/river-protocols/river-layout-v3.xml > river-layout-v3.c
wayland-scanner client-header < /usr/share/river-protocols/river-layout-v3.xml > river-layout-v3.h
gcc -Wall -Wextra -Wpedantic -Wno-unused-parameter -c -o layout.o layout.c
gcc -Wall -Wextra -Wpedantic -Wno-unused-parameter -c -o river-layout-v3.o river-layout-v3.c
gcc -o dgl-river-layout layout.o river-layout-v3.o -lwayland-client

SUDO_CMD=sudo
EXE_PATH=/usr/local/bin/dgl-river-layout
sudo -v 2>/dev/null || SUDO_CMD=doas

[ -L ${EXE_PATH} ] || ${SUDO_CMD} ln -s /home/dgl/.config/river/dgl-river-layout ${EXE_PATH}

rm layout.o
rm river-layout*
