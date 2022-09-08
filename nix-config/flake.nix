{
  # Based on https://github.com/dustinlyons/nixos-config
  description = "Daniels NixOS Config";

  inputs = {
    nixosPkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = inputs@{ self, nixosPkgs, unstable, ... }:
  let
      # Utility function to construct a package set based on the given system
      # along with the shared `nixpkgs` configuration defined in this repo.
      mkPkgsFor = system: pkgset:
        import pkgset {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays =
            # Apply each overlay found in the ./overlays directory
            let path = ./overlays; in with builtins;
            map (n: import (path + ("/" + n)))
                (filter (n: match ".*\\.nix" n != null ||
                            pathExists (path + ("/" + n + "/default.nix")))
                        (attrNames (readDir path)));
        };
      mkNixOSConfiguration = system: modules: nixosPkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixosPkgs.nixosModules.notDetected
        ] ++ modules;
        specialArgs = {
          inherit inputs;
          pkgs = mkPkgsFor system nixosPkgs;
          unstable = mkPkgsFor system inputs.unstable;
        };
      };
  in
  {
    nixosConfigurations = {
      home = mkNixOSConfiguration "x86_64-linux" [
          ./nixos/home.nix
          ./hardware/amd.nix
      ];
      work = mkNixOSConfiguration "x86_64-linux" [
          ./nixos/work.nix
          ./hardware/amd.nix
      ];
      laptop = mkNixOSConfiguration "x86_64-linux" [
          ./nixos/laptop.nix
          ./hardware/schenker.nix
      ];
    };
  };
}
