#!/bin/sh
SCRIPT="$(realpath $0)"
BASEDIR=$(dirname "$SCRIPT")

# install fonts
[ -d "$HOME/.fonts" ] && unlink $HOME/.fonts; ln -s $BASEDIR/dot.fonts $HOME/.fonts
fc-cache

# make dotfiles available
ln -s $BASEDIR/dot.mkshrc $HOME/.mkshrc
ln -s $BASEDIR/dot.mksh_alias $HOME/.mksh_alias
ln -s $BASEDIR/dot.zshrc $HOME/.zshrc
[ -d "$HOME/.dwm-status" ] && unlink $HOME/.dwm-status; ln -s $BASEDIR/dot.dwm-status $HOME/.dwm-status
[ -d "$HOME/.local/bin" ] && unlink $HOME/.local/bin; ln -s $BASEDIR/bin $HOME/.local/bin
[ -d "$HOME/.config/ranger" ] && unlink $HOME/.config/ranger; ln -s $BASEDIR/ranger $HOME/.config/ranger
[ -d "$HOME/.doom.d" ] && unlink $HOME/.doom.d; ln -s $BASEDIR/dot.doom.d $HOME/.doom.d
ln -s $BASEDIR/dot.xinitrc $HOME/.xinitrc
