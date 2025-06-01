{ pkgs, unstable, ...}:
let
  gf = unstable.gf.override {
    extensions = [
      /home/dgl/Sync/extensions_v5/extensions.cpp
    ];
  };

  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-small
      ;
      #(setq org-latex-compiler "xelatex")
  });
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
    pkgs.source-code-pro
    pkgs.ctags
    unstable.chromium
    unstable.firefox
    pkgs.libreoffice-fresh
    pkgs.filezilla
    pkgs.pass
    pkgs.weechat
    pkgs.thunderbird
    pkgs.docker-compose
    pkgs.xclip
    pkgs.usbutils
    pkgs.pciutils
    pkgs.streamlink
    pkgs.yt-dlp
    pkgs.mpv
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
    pkgs.pandoc
    pkgs.obsidian
    pkgs.htop
    tex
  ];
}
