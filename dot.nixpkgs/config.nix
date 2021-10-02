{ pkgs, ... }:

let
  unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  allowUnfree = true;

  packageOverrides = pkgs : with pkgs; rec {
    all = pkgs.buildEnv {
      name = "all";
      paths = [
        nvidia-offload
        ctags
        chromium
        libreoffice-fresh
        filezilla
        fd
        gnupg
        pass
        weechat
        thunderbird
        docker-compose
        xclip
        teams
        taskwarrior
        timewarrior
        syncthing
        usbutils
        pciutils
        streamlink
        mpv
        borgbackup
        spice-gtk
        vlc
        lutris
        wine-staging
      ];
    };
  };
}
