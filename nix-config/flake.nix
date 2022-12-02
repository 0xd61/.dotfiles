{
  # Based on
  # - https://github.com/dustinlyons/nixos-config
  # - https://github.com/jordanisaacs/dotfiles
  # - https://github.com/hlissner/dotfiles
  # - https://github.com/jkachmar/dotnix
  description = "Daniels NixOS Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, unstable, home-manager, ... }:
  let
      # Utility function to construct a package set based on the given system
      # along with the shared `nixpkgs` configuration defined in this repo.
      mkPkgsFor = system: pkgset:
        import pkgset {
          inherit system;
          config.allowUnfree = true;
          overlays =
            # Apply each overlay found in the ./overlays directory
            let path = ./overlays; in with builtins;
            map (n: import (path + ("/" + n)))
                (filter (n: match ".*\\.nix" n != null ||
                            pathExists (path + ("/" + n + "/default.nix")))
                        (attrNames (readDir path)));
        };
      mkNixOSConfiguration = system: modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixpkgs.nixosModules.notDetected
        ] ++ modules;
        specialArgs = {
          inherit inputs;
          pkgs = mkPkgsFor system nixpkgs;
          unstable = mkPkgsFor system inputs.unstable;
        };
      };

      mkHomeManagerConfiguration = system: username: configuration: home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgsFor system nixpkgs;
        modules = [
          {
            _module.args.inputs = inputs;
            _module.args.unstable = mkPkgsFor system unstable;
          }
          {
            home = {
              username = "${username}";
              stateVersion = "22.11";
              homeDirectory = "/home/${username}";
            };
          }
        ] ++ configuration;
      };
  in
  {
    homeConfigurations = {
      dgl = mkHomeManagerConfiguration "x86_64-linux" "dgl" [
        ./users/dgl.nix
      ];
    };

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
