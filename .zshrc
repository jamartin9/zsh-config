#!/usr/bin/env zsh
#
# zsh configuration

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export HISTFILE="${ZDOTDIR}/history"

# p10k instant prompt
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export TERM="xterm-256color"

# add bin packages
export PATH="${HOME}/.cargo/bin:$HOME/.local/bin:${HOME}/.npm-packages/bin:${HOME}/go/bin:${PATH}"

# fix light on my kbd
#[[ ! -f ${HOME}/.Xmodmap ]] && echo "add mod3 = Scroll_Lock" > ${HOME}/.Xmodmap


# custom aliases
[[ -f ${ZDOTDIR}/aliases.sh ]] && source ${ZDOTDIR}/aliases.sh


_zsh_kbd_setup
_zsh_zinit_setup
_zsh_zinit_plugins
_guix_opts default #guixProf default
#guix package -d && guix pull -d
#guix gc
#guix pull
