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
    docker-desktop.enable = true;

    wslConf.interop.appendWindowsPath = false;
  };

  users.users.dgl = {
    extraGroups = [ "wheel" "video" "audio" "lp" "docker" "dialout" "adbusers"]; # Enable ‘sudo’ for the user.
    shell = pkgs.mksh;
  };

  # not working with mksh
  #environment.variables.EDITOR = [ "nvim" ];
  #environment.variables.VISUAL = [ "lite" ];

  #environment.interactiveShellInit = ''
  #  alias vim="nvim"
  #  alias git="/mnt/c/Users/danie/Tools/cmder/vendor/git-for-windows/bin/git.exe"
  #'';

  environment.systemPackages = with pkgs; [
    pinentry-curses
  ];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "curses";
     enableSSHSupport = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    auto-optimise-store = true
  '';

  system.stateVersion = "22.05";
}
