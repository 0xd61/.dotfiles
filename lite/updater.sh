#!/bin/sh
# install/update lite editor
set -e

# fetch sources
REPO="0xd61/lite"
PLUGIN_REPO="rxi/lite-plugins"

LATEST_COMMIT=$(cat ./version | grep "Lite" | cut -d @ -f 2)
PLUGIN_LATEST_COMMIT=$(cat ./version | grep "Plugin" | cut -d @ -f 2)

if which curl ; then
    LATEST_COMMIT=$(curl -s "https://api.github.com/repos/${REPO}/git/refs/heads/custom" | jq -r '.object.sha')
    PLUGIN_LATEST_COMMIT=$(curl -s "https://api.github.com/repos/${PLUGIN_REPO}/git/refs/heads/master" | jq -r '.object.sha')
fi

echo "Lite: $REPO @$LATEST_COMMIT" > version
echo "Plugin: $PLUGIN_REPO @$PLUGIN_LATEST_COMMIT" >> version
[ -f "${LATEST_COMMIT}.tar.gz" ] || { curl -L "https://github.com/${REPO}/archive/${LATEST_COMMIT}.tar.gz" -o "${LATEST_COMMIT}.tar.gz" && tar xvf "${LATEST_COMMIT}.tar.gz"; }
[ -f "${PLUGIN_LATEST_COMMIT}.tar.gz" ] || { curl -L "https://github.com/${PLUGIN_REPO}/archive/${PLUGIN_LATEST_COMMIT}.tar.gz" -o "${PLUGIN_LATEST_COMMIT}.tar.gz" && tar xvf "${PLUGIN_LATEST_COMMIT}.tar.gz"; }

if [ "$([ -f /etc/os-release ] && cat /etc/os-release  | grep -e ^ID= | cut -d= -f 2)" == "nixos" ]; then
    cat << EOF > "./default.nix"
with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "lite";
  version = "${LATEST_COMMIT}";

  src = ../lite;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ SDL2 clang zip unzip binutils go elixir nodejs ];

  patchPhase = ''
    patchShebangs \
        lite-${LATEST_COMMIT}/build.sh \
        lite-${LATEST_COMMIT}/build_release.sh
  '';

  buildPhase = ''
    ./updater.sh --quiet
  '';

  installPhase = ''
    mkdir -p "\$out/bin"
    cp -r data "\$out/bin/"
    cp lite "\$out/bin/"
    cp version "\$out/bin/"
    ls -s "\$out/bin/lite" "\$out/bin/"
    runHook postInstall
  '';

  postInstall = with lib; ''
      wrapProgram \$out/bin/lite --prefix PATH : \${makeBinPath [ go elixir nodejs ]}
  '';

  meta = {
    description = "A lightweight text editor written in Lua";
    homepage = "https://github.com/rxi/lite";
    license = lib.licenses.mit;
  };
}
EOF

nix-env -i -f default.nix

rm "${LATEST_COMMIT}.tar.gz"
rm "${PLUGIN_LATEST_COMMIT}.tar.gz"
rm -rf "lite-${LATEST_COMMIT}"
rm -rf "lite-plugins-${PLUGIN_LATEST_COMMIT}"
else
    # NOTE(dgl): we remove the source dirs here, to prevent an additional downloading when calling the script
    # in the nix build environment

    rm "${LATEST_COMMIT}.tar.gz"
    rm "${PLUGIN_LATEST_COMMIT}.tar.gz"

    cd "lite-${LATEST_COMMIT}"
    ./build_release.sh
    mv lite.zip ..
    cd -
    rm -rf "lite-${LATEST_COMMIT}"

    #LATEST_RELEASE_TAG=$(curl -s "https://api.github.com/repos/${REPO}/releases" | jq -r '.[0].tag_name')
    #curl -L "https://github.com/${REPO}/releases/download/${LATEST_RELEASE_TAG}/lite.zip" -o lite.zip
    #echo $LATEST_RELEASE_TAG > version

    UNZIP_FLAGS="-u";
    [ "$1" == "--quiet" ] && UNZIP_FLAGS="-o"

    unzip "${UNZIP_FLAGS}" "lite.zip" -x "data/user/init.lua" -x "data/plugins/language_c.lua"
    rm "lite.zip"

    # NOTE(dgl): if we only handle the && case, we still get an error code 1
    [ ! -d "plugins.repo" ] || rm -rf "plugins.repo"
    mv "lite-plugins-${PLUGIN_LATEST_COMMIT}" "plugins.repo"

    PLUGIN_SRC="./plugins.repo/plugins"
    PLUGIN_DEST="./data/plugins"
    BLACKLIST="language_cpp.lua language_c.lua"

    for f in ${PLUGIN_SRC}/*; do
        FILENAME=$(basename $f)

        SKIP="false";
        for plugin in ${BLACKLIST}; do
            if [ "$plugin" == "${FILENAME}" ]; then
                SKIP="true"
            fi
        done

        if [ "${SKIP}" == "false" ] && [ -f "${PLUGIN_DEST}/${FILENAME}" ]; then
            cp "${PLUGIN_SRC}/${FILENAME}" "${PLUGIN_DEST}/${FILENAME}"
        fi
    done
fi
