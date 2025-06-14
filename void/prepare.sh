#!/bin/bash

PACKAGE="${1?Please provide a package name}"
COMMAND="${2:-pkg}"

pushd repo/void-packages
git clean -fd
git reset --hard
./xbps-src binary-bootstrap
popd

git submodule update --remote repo/void-packages

cp -rf repo/dgl-packages/srcpkgs/* repo/void-packages/srcpkgs
cat repo/dgl-packages/shlibs.frag >> repo/void-packages/common/shlibs

pushd repo/void-packages
./xbps-src ${COMMAND} ${PACKAGE}
