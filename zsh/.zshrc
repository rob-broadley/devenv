# ****************************************************************************
# Set up paths
# ****************************************************************************
ZSH_DIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
PLUGIN_DIR=$ZSH_DIR/plugins
ZSH_DATA=$HOME/.local/share/zsh
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}



# ****************************************************************************
# Powerlevel10k instant prompt
# ****************************************************************************
# Enable Powerlevel10k instant prompt. Should stay close to the top of $ZSH_DIR/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi



# ****************************************************************************
# Plugins
# ****************************************************************************
source $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh



# ****************************************************************************
# Functions
# ****************************************************************************
fpath=($ZSH_DIR/functions $fpath)
autoload -Uz replace
autoload -Uz start-keychain
autoload -Uz venvactivate
autoload -Uz venvnew
autoload -Uz _venv_auto_activate
autoload -Uz _venv_set_paths

# python-env (Auto activate a python virtualenv when entering the project directory)
VENV=".venv"

chpwd_functions+=(_venv_auto_activate)
precmd_functions=(_venv_auto_activate $precmd_functions)
# ----------------------------------------------------------------------------



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



# ****************************************************************************
# Theme
# ****************************************************************************
source $ZSH_DIR/themes/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit $ZSH_DIR/.p10k.zsh.
[[ ! -f $ZSH_DIR/.p10k.zsh ]] || source $ZSH_DIR/.p10k.zsh



# ****************************************************************************
# Aliases
# ****************************************************************************

# General
alias ls='ls --color'
alias ll='ls -l --color'
alias la='ls -la --color'
# ----------------------------------------------------------------------------


# Git
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias gb='git branch'
alias gsw='git switch'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gcfix='git commit --fixup'
alias gr='git rebase --interactive'
alias grm='git rebase --interactive origin/HEAD'
alias gsm='git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@")'
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
alias pipl='pip list'
# ----------------------------------------------------------------------------


# Ranger
alias fm='ranger'
alias fmcd='ranger --choosedir=$XDG_CACHE_HOME/.rangerdir; LASTDIR=`cat $XDG_CACHE_HOME/.rangerdir`; cd "$LASTDIR"'
# ----------------------------------------------------------------------------


# VI
alias vim='nvim'
alias vi='nvim'
alias vimdiff='nvim -d'

# tmux
alias tmux0='tmux new-session -A -s 0'
# ----------------------------------------------------------------------------
