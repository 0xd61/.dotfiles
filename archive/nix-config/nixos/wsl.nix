{ lib, pkgs, config, unstable, modulesPath, ... }:

with lib;
let
  nixos-wsl = import "${fetchTarball { url = "https://github.com/nix-community/NixOS-WSL/archive/20a1f182aed3d2bbc72f62f5814fc3dd34a1cf0c.tar.gz"; sha256 = "sha256:0fzvf90ms3n04n8iamgx26j66zz3p7jqkkjhs9s6qd38yk8jdxqb"; } }";
  common-packages = import ./packages.nix { pkgs = pkgs; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    defaultUser = "dgl";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;
    nativeSystemd = true;

    wslConf.automount.root = "/mnt";
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
  services.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

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
