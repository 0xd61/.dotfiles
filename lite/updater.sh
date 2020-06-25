#!/bin/sh
# install/update lite editor
set -e

REPO="rxi/lite"
LATEST_RELEASE_TAG=$(curl -s "https://api.github.com/repos/${REPO}/releases" | jq -r '.[0].tag_name')

curl -L "https://github.com/${REPO}/releases/download/${LATEST_RELEASE_TAG}/lite.zip" -o lite.zip

unzip -u lite.zip -x data/user/init.lua
rm lite.zip
