#!/usr/bin/env bash

sudo ifconfig wlp2s0 up

if [ ! -z "$1" ] && [ ! -z "$2" ]; then
    wpa_passphrase "$1"  "$2" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
fi

sudo wpa_supplicant -B -iwlp2s0 -c /etc/wpa_supplicant/wpa_supplicant.conf -Dwext
