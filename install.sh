#!/bin/sh
SCRIPT="$(realpath $0)"
BASEDIR=$(dirname "$SCRIPT")

# install fonts
[ -d "$HOME/.fonts" ] && unlink $HOME/.fonts; ln -s $BASEDIR/dot.fonts $HOME/.fonts
fc-cache

# make dotfiles available
ln -s $BASEDIR/dot.mkshrc $HOME/.mkshrc
ln -s $BASEDIR/dot.zshrc $HOME/.zshrc
ln -s $BASEDIR/dot.spacemacs $HOME/.spacemacs
[ -d "$HOME/.dwm-status" ] && unlink $HOME/.dwm-status; ln -s $BASEDIR/dot.dwm-status $HOME/.dwm-status
ln -s $BASEDIR/dot.xinitrc $HOME/.xinitrc
