
# Perform initialization only when running interactively
case $- in
    *i*) ;;
      *) return;;
esac


# =============================================================================
# System settings

export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCREEN_SCALE_FACTORS=1


# =============================================================================
# Preparation for color output

case "$TERM" in
    xterm-color|*-256color) color_mode=yes;;
esac


# =============================================================================
# Bash settings

shopt -s autocd cdspell
shopt -s globstar nocaseglob
shopt -s checkwinsize
shopt -s histappend cmdhist no_empty_cmd_completion

HISTCONTROL=ignoreboth
HISTSIZE=20000
HISTFILESIZE=$HISTSIZE
HISTIGNORE="&:exit:logout:ls:bg *:fg *:ls:ll:ls -la:clear:mc:pwd"

if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

FIGNORE=".swp:.bak:~:.DS_Store"

alias sudo="sudo "


# =============================================================================
# man and less

if [[ -n $color_mode ]]; then
    export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
    export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
    export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
    export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
    export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
    export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
    export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
    export GROFF_NO_SGR=1                  # for konsole and gnome-terminal
fi

export LESSSECURE=1
export LESSCHARSET=utf-8
export MANPAGER='less -s -M +Gg'

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"


# =============================================================================
# File system navigation

if [[ -n $color_mode && -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

alias ..="cd .."
alias ...="cd ../.."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."

alias path='echo -e ${PATH//:/\\n}'

# =============================================================================
# Modify environment when in a SSH session

if [[ -n $SSH_CONNECTION ]]; then
    :
fi


# =============================================================================
# Funky aliases and functions

md() {
    # md [DIR...]
    # Create one or more directories, including necessary parents
    # If a single parameter is given, it will prepare an appropriate
    # "cd" command with absolute path to the readline history
    mkdir -p "$@"
    if [[ $? -eq 0 && $# -eq 1 && -d $1 ]]; then
        history -s "${FUNCNAME[0]} $*"
        local ABSDIR=$( cd "$1" >/dev/null 2>&1 && pwd )
        if [[ -n $ABSDIR ]]; then
            history -s "cd $ABSDIR"
        fi
    fi
}

_readline_prepend_sudo() {
    if [[ -z $READLINE_LINE || ! $READLINE_LINE =~ ^sudo( .*)?$ ]]; then
        READLINE_LINE="sudo $READLINE_LINE"
        READLINE_POINT=$(( $READLINE_POINT + 5 ))
    fi
}

# Pressing F1 will prepend "sudo" to the current command line (unless there
# is already one), keeping cursor position intact
bind -x '"\eOP":"_readline_prepend_sudo"'


# =============================================================================
# Allow for custom overrides/additions

for RCFILE in ~/.bash_{aliases,extra}; do
    [[ -r $RCFILE ]] && source "$RCFILE"
done

