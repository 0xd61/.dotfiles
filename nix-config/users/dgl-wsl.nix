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
  programs.vim.extraConfig = builtins.readFile ../dot.vimrc;

  home.packages = [
    pkgs.neovim
    pkgs.source-code-pro
    pkgs.ctags
    pkgs.pass
    pkgs.weechat
    pkgs.xclip
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
    pkgs.htop
  ];
}
