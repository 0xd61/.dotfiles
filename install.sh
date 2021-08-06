#!/bin/sh
SCRIPT="$(realpath $0)"
BASEDIR=$(dirname "$SCRIPT")

# install fonts
[ -d "$HOME/.local/share/fonts" ] && unlink $HOME/.local/share/fonts; ln -s $BASEDIR/dot.fonts $HOME/.local/share/fonts
fc-cache

# make dotfiles available
ln -s $BASEDIR/dot.mkshrc $HOME/.mkshrc
ln -s $BASEDIR/dot.mksh_alias $HOME/.mksh_alias
ln -s $BASEDIR/dot.mksh_env $HOME/.mksh_env
ln -s $BASEDIR/dot.taskrc $HOME/.taskrc
#ln -s $BASEDIR/dot.zshrc $HOME/.zshrc
ln -s $BASEDIR/dot.asoundrc $HOME/.asoundrc
ln -s $BASEDIR/dot.vimrc $HOME/.vimrc
ln -s $BASEDIR/dot.ctags $HOME/.ctags
ln -s $BASEDIR/dot.nbrc $HOME/.nbrc
ln -s $BASEDIR/dot.gdbinit $HOME/.gdbinit
[ -d "$HOME/.vim" ] && unlink $HOME/.vim; ln -s $BASEDIR/dot.vim $HOME/.vim
[ -d "$HOME/.dwm-status" ] && unlink $HOME/.dwm-status; ln -s $BASEDIR/dot.dwm-status $HOME/.dwm-status
[ -d "$HOME/.local/bin" ] && unlink $HOME/.local/bin; ln -s $BASEDIR/bin $HOME/.local/bin
#[ -d "$HOME/.config/ranger" ] && unlink $HOME/.config/ranger; ln -s $BASEDIR/ranger $HOME/.config/ranger
[ -d "$HOME/.doom.d" ] && unlink $HOME/.doom.d; ln -s $BASEDIR/dot.doom.d $HOME/.doom.d
[ -d "$HOME/.weechat" ] && unlink $HOME/.weechat; ln -s $BASEDIR/dot.weechat $HOME/.weechat
ln -s $BASEDIR/dot.xinitrc $HOME/.xinitrc

# install/update lite editor
cd lite > /dev/null
echo
echo "#### Installing Lite editor ####"
/bin/sh ./updater.sh

cd - > /dev/null
