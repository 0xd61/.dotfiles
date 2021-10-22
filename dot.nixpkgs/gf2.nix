with import <nixpkgs> {};
let
  vim_configured = pkgs.vim_configurable.customize {
    name = "vim";
    wrapGui = true;
    vimrcConfig.customRC = "";
  };
in
stdenv.mkDerivation rec {
  pname = "gf2";
  version = "e49f7895fa2b568631f220f7d20b52c3d0d5a99a";

  src = fetchgit {
    url = "https://github.com/nakst/gf.git";
    rev = "${version}";
    sha256 = "0mhwr8f84mpcakqbavxsg575jli5mrff5y6q5bizcy6af69bpwwm";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ xorg.libX11 gdb ];

  patchPhase = ''
    echo #!/usr/bin/env bash > build.sh
    patchShebangs \
    build.sh

    #sed -i 's/vimServerName = "GVIM"/vimServerName = "VIM"/' gf2.cpp
  '';

  buildPhase = ''
    extra_flags=-DUI_FREETYPE_SUBPIXEL ./build.sh
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp gf2 "$out/bin/"
    runHook postInstall
  '';

  postInstall = with lib; ''
    wrapProgram $out/bin/gf2 --prefix PATH : ${makeBinPath [ gdb vim_configured ]}
  '';

  meta = with lib; {
    description = "gf – A GDB Frontend";
    homepage = "https://github.com/nakst/gf";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

