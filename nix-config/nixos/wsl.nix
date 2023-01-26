{ lib, pkgs, config, unstable, modulesPath, ... }:

with lib;
let
  nixos-wsl = import "${fetchTarball { url = "https://github.com/nix-community/NixOS-WSL/archive/17f1ff26c7540e6bbd13e5cb7cc387310b4ec5ae.tar.gz"; sha256 = "sha256:0njm448mp2b98v2a9ja2canx8hwj2gnb5d4bpaxlz4ihj4m5pgqj"; } }";
  common-packages = import ./packages.nix { pkgs = pkgs; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "dgl";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = false;
  };

  users.users.dgl = {
    extraGroups = [ "wheel" "video" "audio" "lp" "docker" "dialout" "adbusers"]; # Enable ‘sudo’ for the user.
    shell = pkgs.mksh;
  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";
}
