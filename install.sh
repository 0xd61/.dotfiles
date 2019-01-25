#!/bin/sh
SCRIPT="$(realpath $0)"
BASEDIR=$(dirname "$SCRIPT")

#ln -s $BASEDIR/dot.mkshrc $HOME/.mkshrc
ln -s $BASEDIR/dot.zshrc $HOME/.zshrc
ln -s $BASEDIR/dot.spacemacs $HOME/.spacemacs
