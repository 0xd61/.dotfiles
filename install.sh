#!/bin/sh
SCRIPT="$(realpath $0)"
BASEDIR=$(dirname "$SCRIPT")

# install fonts
[ -d "$HOME/.local/share/fonts" ] && unlink $HOME/.local/share/fonts; ln -s $BASEDIR/dot.fonts $HOME/.local/share/fonts
fc-cache

# make dotfiles available
ln -s $BASEDIR/dot.mkshrc $HOME/.mkshrc
ln -s $BASEDIR/dot.bashrc $HOME/.bashrc
ln -s $BASEDIR/dot.dgl_alias $HOME/.mksh_alias #deprecated
ln -s $BASEDIR/dot.dgl_env $HOME/.mksh_env     #deprecated
ln -s $BASEDIR/dot.dgl_alias $HOME/.dgl_alias
ln -s $BASEDIR/dot.dgl_env $HOME/.dgl_env
[ -d "$HOME/.config/river" ] && unlink $HOME/.config/river; ln -s $BASEDIR/dot.river $HOME/.config/river
[ -d "$HOME/.config/waybar" ] && unlink $HOME/.config/waybar; ln -s $BASEDIR/dot.waybar $HOME/.config/waybar
[ -d "$HOME/.emacs.d" ] && unlink $HOME/.emacs.d; ln -s $BASEDIR/dot.emacs.d $HOME/.emacs.d
[ -d "$HOME/.qe" ] && unlink $HOME/.qe; ln -s $BASEDIR/dot.qe $HOME/.qe
[ -d "$HOME/.runit" ] && unlink $HOME/.runit; ln -s $BASEDIR/dot.runit $HOME/.runit
ln -s $BASEDIR/dot.gf2_config.ini $HOME/.config/gf2_config.ini
[ -d "$HOME/.config/nvim" ] && unlink $HOME/.config/nvim; ln -s $BASEDIR/dot.nvim $HOME/.config/nvim
[ -d "$HOME/.config/focus-editor" ] && unlink $HOME/.config/focus-editor; ln -s $BASEDIR/dot.focus $HOME/.config/focus-editor
[ -d "$HOME/.local/bin" ] && unlink $HOME/.local/bin; ln -s $BASEDIR/bin $HOME/.local/bin
ln -s $BASEDIR/dot.xprofile $HOME/.xprofile
ln -s $BASEDIR/dot.xinitrc $HOME/.xinitrc
[ -d "$HOME/.config/mpv" ] && unlink $HOME/.config/mpv; ln -s $BASEDIR/mpv $HOME/.config/mpv
