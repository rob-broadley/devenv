ZSH_DIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
PLUGIN_DIR=$ZSH_DIR/plugins
ZSH_DATA=$HOME/.local/share/zsh
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}


# ****************************************************************************
# Plugins
# ****************************************************************************
source $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh



# ****************************************************************************
# Config
# ****************************************************************************

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
unsetopt COMPLETE_ALIASES
# ----------------------------------------------------------------------------


# History substring search
# bindkey "^[[A" history-substring-search-up
# bindkey "^[[B" history-substring-search-down
# bindkey -M viins "^[[A" history-substring-search-up
# bindkey -M viins "^[[B" history-substring-search-down
# bindkey -M vicmd "^[[A" history-substring-search-up
# bindkey -M vicmd "^[[B" history-substring-search-down
setopt HIST_FIND_NO_DUPS
# Set Colors
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=black,bold'
# ----------------------------------------------------------------------------


# History
HISTSIZE=5000               # How many lines of history to keep in memory
HISTFILE=$ZSH_DATA/history  # Where to save history to disk
SAVEHIST=5000               # Number of history entries to save to disk
# HISTDUP=erase             # Erase duplicates in the history file
setopt appendhistory        # Append history to the history file (no overwriting)
setopt sharehistory         # Share history across terminals
setopt incappendhistory     # Immediately append to the history file, not just when a term is killed
# ----------------------------------------------------------------------------


# Key bindings
# create a zkbd compatible hash
typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"
# Set up key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        history-substring-search-up
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      history-substring-search-down
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete
# Make sure the terminal is in application mode, when zle is active.
# Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start {
		echoti smkx
	}
	function zle_application_mode_stop {
		echoti rmkx
	}
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
# ----------------------------------------------------------------------------


# Powerlevel9k
POWERLEVEL9K_INSTALLATION_PATH=$ZSH_DIR/themes/powerlevel9k
POWERLEVEL9K_MODE='nerdfont-fontconfig'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon user dir dir_writable virtualenv vcs status newline vi_mode)
POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=""
POWERLEVEL9K_PROMPT_ON_NEWLINE=false
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
# OS Icon
POWERLEVEL9K_OS_ICON_BACKGROUND="silver"
if [[ $DISTRO == "ubuntu" ]]; then
    POWERLEVEL9K_OS_ICON_FOREGROUND="202"  # Orange
else
    POWERLEVEL9K_OS_ICON_FOREGROUND="027"  # Blue
fi
# User
POWERLEVEL9K_USER_DEFAULT_BACKGROUND="grey"
POWERLEVEL9K_USER_DEFAULT_FOREGROUND="silver"
# Path
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="cyan"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="black"
POWERLEVEL9K_DIR_HOME_BACKGROUND="cyan"
POWERLEVEL9K_DIR_HOME_FOREGROUND="black"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND="cyan"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="black"
POWERLEVEL9K_DIR_ETC_BACKGROUND="cyan"
POWERLEVEL9K_DIR_ETC_FOREGROUND="black"
# Python
POWERLEVEL9K_VIRTUALENV_FOREGROUND="black"
# Version Control
POWERLEVEL9K_VCS_CLEAN_FOREGROUND="black"
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND="black"
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND="black"
POWERLEVEL9K_VCS_SHORTEN_LENGTH=20
POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=20
POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_VCS_SHORTEN_DELIMITER=".."
POWERLEVEL9K_STATUS_OK_BACKGROUND="grey"
# VI Mode
POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND="grey"
POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND="silver"
POWERLEVEL9K_VI_MODE_INSERT_BACKGROUND="grey"
POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND="silver"
POWERLEVEL9K_VI_COMMAND_MODE_STRING=":"
POWERLEVEL9K_VI_INSERT_MODE_STRING="%%"
# ----------------------------------------------------------------------------



# ****************************************************************************
# Theme
# ****************************************************************************
source $ZSH_DIR/themes/powerlevel9k/powerlevel9k.zsh-theme



# ****************************************************************************
# Functions
# ****************************************************************************

# python-env (Auto activate a python virtualenv when entering the project directory)
VENV=".venv"

function venvnew() {
    VENV_DIR="$PWD/$VENV"
    VENV_ACTIVATE="$VENV_DIR/bin/activate"
    if [ -e $VENV_DIR ]; then
        echo "Could not create environment: one already exists!"
    else
        echo "Creating $VENV_DIR"
        python3 -m venv $VENV_DIR
        source $VENV_ACTIVATE
        pip install -U pip
        pip install black pylint python-language-server pydocstyle
    fi
}

function venvactivate() {
    VENV_DIR="$PWD/$VENV"
    VENV_ACTIVATE="$VENV_DIR/bin/activate"
    if [ -x $VENV_ACTIVATE ]; then
        echo "Could not activate environment ($VENV_ACTIVATE)!"
    else
        # Check to see if already activated to avoid redundant activating
        if [[ "$VIRTUAL_ENV" != "$VENV_DIR" ]]; then
            source $VENV_ACTIVATE
        fi
    fi
}

function _virtualenv_auto_activate() {
    VENV_DIR="$PWD/$VENV"
    VENV_ACTIVATE="$VENV_DIR/bin/activate"
    if [[ -f $VENV_ACTIVATE ]]; then
        venvactivate
    fi
}

chpwd_functions+=(_virtualenv_auto_activate)
precmd_functions=(_virtualenv_auto_activate $precmd_functions)
# ----------------------------------------------------------------------------



# ****************************************************************************
# Aliases
# ****************************************************************************

# General
alias ls='ls --color'
alias ll='ls -l --color'
# ----------------------------------------------------------------------------


# Git
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias gl1='git log --oneline'
alias gltree='git log --graph --oneline'
alias gb='git branch'
alias ga='git add'
alias gc='git commit -S'
alias gca='git commit -S --amend'
alias gcfix='git commit -S --fixup'
alias gri='git rebase -S -i'
alias grs='git rebase -S -i --autosquash'
alias grsm='git rebase -S -i --autosquash origin/master'
alias grsd='git rebase -S -i --autosquash origin/develop'
alias gcm='git checkout master'
alias gcd='git checkout develop'
# ----------------------------------------------------------------------------


# Python
alias py='python'
alias ipy='ipython'
alias py3='python3'
alias ipy3='ipython3'
# pip
alias pipi='pip install'
alias pipu='pip uninstall'
alias pips='pip search'
alias pipf='pip freeze'
# ----------------------------------------------------------------------------


# Ranger
alias fm='ranger'
alias fmcd='ranger --choosedir=$XDG_CACHE_HOME/.rangerdir; LASTDIR=`cat $XDG_CACHE_HOME/.rangerdir`; cd "$LASTDIR"'
# ----------------------------------------------------------------------------


# VI
alias vim='nvim'
alias vi='nvim'
alias vimdiff='nvim -d'
# ----------------------------------------------------------------------------
