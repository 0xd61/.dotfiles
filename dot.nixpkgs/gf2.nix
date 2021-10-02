with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "gf2";
  version = "e49f7895fa2b568631f220f7d20b52c3d0d5a99a";

  src = fetchgit {
    url = "https://github.com/nakst/gf.git";
    rev = "${version}";
    sha256 = "0mhwr8f84mpcakqbavxsg575jli5mrff5y6q5bizcy6af69bpwwm";
  };

  buildInputs = [ xorg.libX11 gdb ];

  patchPhase = ''
    echo #!/usr/bin/env bash > build.sh
    patchShebangs \
    build.sh
  '';

  buildPhase = ''
    ./build.sh
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp gf2 "$out/bin/"
  '';

  meta = with lib; {
    description = "gf – A GDB Frontend";
    homepage = "https://github.com/nakst/gf";
    license = licenses.mit;
    maintainers = teams.sage.members;
  };
}
