{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    clang
    binutils
    zip
    unzip
    SDL2
  ];

   shellHook = ''
       mksh || zsh || bash
  '';

   NIX_ENFORCE_PURITY=0;
}
