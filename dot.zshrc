# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=4096
SAVEHIST=4096
setopt appendhistory notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/danielg/.zshrc'

autoload -Uz compinit 
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;
# End of lines added by compinstall

function nonzero_return() {
	RETVAL=$?
	[ $RETVAL -ne 0 ] && echo "$RETVAL"
}

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{black}@%f%F{white}%b%f'
 
# Set up the prompt (with git branch name)
setopt PROMPT_SUBST

PROMPT=$'%B%F{green}[%40<…<%~%<<%f${vcs_info_msg_0_}%F{green}]%f\n%f%F{red}%(?..%? )%f%F{white}%(!.#.$)%f%b '
