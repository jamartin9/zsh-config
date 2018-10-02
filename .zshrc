#!/usr/bin/env zsh
#
# zsh configuration

export PATH="${PATH}:${HOME}/.cargo/bin:${HOME}/bin:$HOME/.local/bin:${HOME}/.npm-packages/bin:${HOME}/go/bin"
export TERM="xterm-256color"
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# custom alias
[[ -f ${CUR_DIR}/aliases.sh ]] && source ${CUR_DIR}/aliases.sh


# fix light on my kbd
[[ ! -f ${HOME}/.Xmodmap ]] && echo "add mod3 = Scroll_Lock" > ${HOME}/.Xmodmap

# Setup zplugin
ZPLG_HOME="${ZDOTDIR:-$CUR_DIR}/.zplugin"
if [[ ! -d $ZPLG_HOME ]]; then
    # clone zplugin
    mkdir ${ZPLG_HOME}
    chmod g-rwX ${ZPLG_HOME}
    git clone --depth 1 https://github.com/zdharma/zplugin.git ${ZPLG_HOME}/bin
    # load zplugin for module/plugins
    source "${ZPLG_HOME}/bin/zplugin.zsh"
    autoload -Uz _zplugin
    (( ${+_comps} )) && _comps[zplugin]=_zplugin
    # build zplugin module for compiling scripts/plugins and reports
    zplugin module build
    # load module
    module_path+=( "${ZPLG_HOME}/bin/zmodules/Src" )
    zmodload zdharma/zplugin
else
    # load module/zplugin
    module_path+=( "${ZPLG_HOME}/bin/zmodules/Src" )
    zmodload zdharma/zplugin
    source "${ZPLG_HOME}/bin/zplugin.zsh"
    autoload -Uz _zplugin
    (( ${+_comps} )) && _comps[zplugin]=_zplugin
fi

autoload -Uz zkbd # key config
[[ ! -f ${ZDOTDIR:-$CUR_DIR}/.zkbd/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}} ]] && zkbd
source ${HOME}/.zkbd/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}}
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]} ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[PageUp]} ]] && bindkey "${key[PageUp]}" up-line-or-history
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[PageDown]} ]] && bindkey "${key[PageDown]}" down-line-or-history
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Left]} ]] && bindkey "${key[Left]}" backward-char
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search
[[ -n ${key[Right]} ]] && bindkey "${key[Right]}" forward-char

# prompt theme
zplugin ice silent wait'!0' atload'powerlevel9k_prepare_prompts' depth'1'
zplugin light bhilburn/powerlevel9k

# history
zplugin ice silent pick"history.zsh"
zplugin snippet OMZ::lib/history.zsh

# completion
zplugin ice silent blockf wait'0' depth'1'
zplugin light zsh-users/zsh-completions

# auto suggest
ZSH_AUTOSUGGEST_USE_ASYNC="y"
zplugin ice silent wait'0' atload'_zsh_autosuggest_start' cloneopts'-b develop --single-branch' depth'1'
zplugin light zsh-users/zsh-autosuggestions

# syntax highlighting
zplugin ice silent wait'0' atinit'zpcompinit; zpcdreplay' depth'1'
zplugin light zdharma/fast-syntax-highlighting

# prompt
PROMPT_EOL_MARK=''

# colors for prompt
autoload -Uz colors && colors
# prompts
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{$fg[green]%}$> "
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

# context
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND="black"
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND="blue"
POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND="black"
POWERLEVEL9K_CONTEXT_ROOT_FOREROUND="blue"
POWERLEVEL9K_CONTEXT_SUDO_BACKGROUND="black"
POWERLEVEL9K_CONTEXT_SUDO_FOREROUND="blue"
POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND="black"
POWERLEVEL9K_CONTEXT_REMOTE_FOREROUND="blue"
POWERLEVEL9K_CONTEXT_REMOTE_SUDO_BACKGROUND="black"
POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREROUND="blue"
DEFAULT_USER=$USER
POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true

# status
POWERLEVEL9K_STATUS_CROSS=true

# dir
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=".."
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_first_and_last"
POWERLEVEL9K_DIR_HOME_BACKGROUND="black"
POWERLEVEL9K_DIR_HOME_FOREGROUND="blue"
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="black"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="blue"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND="black"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="blue"
POWERLEVEL9K_DIR_ETC_BACKGROUND="black"
POWERLEVEL9K_DIR_ETC_FOREGROUND="blue"

# time
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S %m/%d/%y}"
POWERLEVEL9K_TIME_BACKGROUND="black"
POWERLEVEL9K_TIME_FOREGROUND="blue"

# vcs
POWERLEVEL9K_VCS_SHORTEN_LENGTH=7
POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=7
POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_VCS_SHORTEN_DELIMITER="..."
POWERLEVEL9K_VCS_CLEAN_BACKGROUND="black"
POWERLEVEL9K_VCS_CLEAN_FOREGROUND="blue"
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND="black"
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND="blue"
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND="black"
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND="blue"
