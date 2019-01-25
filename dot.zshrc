if [[ -z $SSH_TTY ]] && [[ -z $DISPLAY ]]; then
	setleds -D +num
fi

HISTFILE=~/.zhistfile
HISTSIZE=4096
SAVEHIST=4096
setopt appendhistory notify HIST_IGNORE_SPACE 
unsetopt beep
bindkey -v
zstyle ':completion:*' menu select
zstyle :compinstall filename '/home/danielg/.zshrc'
setopt COMPLETE_ALIASES

# Function to determine the need of a zcompile. If the .zwc file
# does not exist, or the base file is newer, we need to compile.
# These jobs are asynchronous, and will not impact the interactive shell
zcompare() {
  if [[ -s ${1} && ( ! -s ${1}.zwc || ${1} -nt ${1}.zwc) ]]; then
   builtin zcompile ${1}
  fi
}

# cache autocomplete for 24 hours
autoload -Uz compinit 
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
	zcompare ${ZDOTDIR}.zcompdump
fi;

# compile zshrc file
zcompare ${ZDOTDIR:-${HOME}}/.zshrc

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{black}@%f%F{white}%b%f'
 
# Set up the prompt (with git branch name)
setopt PROMPT_SUBST

PROMPT=$'%B%F{green}[%40<…<%~%<<%f${vcs_info_msg_0_}%F{green}]%f\n%f%F{red}%(?..%? )%f%F{white}%(!.#.$)%f%b '

# create persistand dirstack
DIRSTACKFILE="$HOME/.zdirfile"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(uf)"$(< $DIRSTACKFILE)"} )
  #[[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
# persist path in dirstack
dirs!() {
  dirs $@
  print -l $PWD ${(u)dirstack} | tail -n +2 > $DIRSTACKFILE
}
DIRSTACKSIZE=20
setopt PUSHD_SILENT PUSHD_TO_HOME PUSHD_IGNORE_DUPS

# customise your favourite editor here; the first one found is used
for EDITOR in "${EDITOR:-}" emacs vim jupp jstar mcedit ed vi; do
	EDITOR=$(builtin whence -p "$EDITOR") || EDITOR=
	[[ -n $EDITOR && -x $EDITOR ]] && break
	EDITOR=
done

# colorful man pages
builtin export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
builtin export LESS_TERMCAP_md=$'\e[1;32m'     # begin blink
builtin export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
builtin export LESS_TERMCAP_so=$'\e[01;35m'    # begin reverse video
builtin export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
builtin export LESS_TERMCAP_us=$'\e[4;33m'     # begin underline
builtin export LESS_TERMCAP_ue=$'\e[0m'        # reset underline


builtin alias ls=' ls --color' l='ls -F' la='l -a' ll='l -l' lo='l -alo'
builtin alias grep='grep --colour=auto'
builtin alias egrep='egrep --colour=auto'
builtin alias fgrep='fgrep --colour=auto'
builtin alias cd=' cd'


# add local bin folders to path
for p in ~/.local/bin ~/bin; do
	[[ -d $p/. ]] || builtin continue
	[[ $PATHSEP$PATH$PATHSEP = *"$PATHSEP$p$PATHSEP"* ]] || \
	    PATH=$p$PATHSEP$PATH
done


# custom 
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
export GOROOT=/usr/lib/go
export GOPATH=$HOME/Code/Go

export PKG_CONFIG_PATH=/opt/oracle/instantclient_18_3

export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

