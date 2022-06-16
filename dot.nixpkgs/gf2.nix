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
  version = "c62c4a992268e5fc032a11bbf6298d719d61609d";

  src = fetchgit {
    url = "https://github.com/nakst/gf.git";
    rev = "${version}";
    sha256 = "1635kiayqwfh0n6xrh0r1b909vxmyxy2vqrbap984f8lz1f18lrr";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ xorg.libX11 gdb freetype ];

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

