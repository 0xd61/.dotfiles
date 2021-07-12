#!/bin/sh
# install/update lite editor
set -e

REPO="0xd61/lite"
LATEST_COMMIT=$(curl -s "https://api.github.com/repos/${REPO}/git/refs/heads/custom" | jq -r '.object.sha')
curl -L "https://github.com/${REPO}/archive/${LATEST_COMMIT}.zip" -o ${LATEST_COMMIT}.zip
echo Lite: $REPO @$LATEST_COMMIT> version
unzip -u ${LATEST_COMMIT}.zip
rm ${LATEST_COMMIT}.zip
cd lite-${LATEST_COMMIT}
./build_release.sh
mv lite.zip ..
cd -
rm -rf lite-${LATEST_COMMIT}

#LATEST_RELEASE_TAG=$(curl -s "https://api.github.com/repos/${REPO}/releases" | jq -r '.[0].tag_name')
#curl -L "https://github.com/${REPO}/releases/download/${LATEST_RELEASE_TAG}/lite.zip" -o lite.zip
#echo $LATEST_RELEASE_TAG > version


unzip -u lite.zip -x data/user/init.lua
rm lite.zip

PLUGIN_REPO="rxi/lite-plugins"
PLUGIN_LATEST_COMMIT=$(curl -s "https://api.github.com/repos/${PLUGIN_REPO}/git/refs/heads/master" | jq -r '.object.sha')
curl -L "https://github.com/${PLUGIN_REPO}/archive/${PLUGIN_LATEST_COMMIT}.zip" -o ${PLUGIN_LATEST_COMMIT}.zip
echo Plugin: $PLUGIN_REPO @$PLUGIN_LATEST_COMMIT >> version
unzip -u ${PLUGIN_LATEST_COMMIT}.zip
rm ${PLUGIN_LATEST_COMMIT}.zip
rm -rf plugins.repo
mv lite-plugins-${PLUGIN_LATEST_COMMIT} plugins.repo

PLUGIN_SRC="./plugins.repo/plugins"
PLUGIN_DEST="./data/plugins"
for f in ${PLUGIN_SRC}/*; do filename=$(basename $f); [ -f "${PLUGIN_DEST}/$filename" ] && cp ${PLUGIN_SRC}/$filename ${PLUGIN_DEST}/$filename; done

