{ pkgs, unstable, ...}:
let
  gf = unstable.gf.override {
    extensions = [
      /home/dgl/Sync/extensions_v5/extensions.cpp
    ];
  };
in
{
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName  = "Daniel Glinka";
    userEmail = "dgl@degit.co";
  };

  programs.vim.extraConfig = builtins.readFile ../dot.vimrc;

  home.packages = [
    pkgs.ctags
    unstable.chromium
    unstable.firefox
    pkgs.libreoffice-fresh
    pkgs.filezilla
    pkgs.pass
    pkgs.git-crypt
    pkgs.weechat
    pkgs.thunderbird
    pkgs.docker-compose
    pkgs.xclip
    pkgs.syncthing
    pkgs.usbutils
    pkgs.pciutils
    pkgs.streamlink
    pkgs.yt-dlp
    pkgs.mpv
    pkgs.openvpn
    pkgs.flameshot
    pkgs.v4l-utils
    pkgs.git
    pkgs.fd
    pkgs.gnupg
    pkgs.jq
    pkgs.zip
    pkgs.unzip
    pkgs.xz
    pkgs.man-pages
    pkgs.man-pages-posix
    pkgs.qemu
    pkgs.virt-viewer
    pkgs.spice-gtk
    pkgs.broot
    gf
  ];
}
