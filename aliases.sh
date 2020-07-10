#!/usr/bin/env zsh

alias javaListProps="java -server -XX:+PrintFlagsFinal -XX:+UnlockDiagnosticVMOptions --version"
alias javaToolOptions="export JAVA_TOOL_OPTIONS='-XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI -XX:+UseJVMCICompiler -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=heapdump.hprof -XX:StartFlightRecording=disk=true,dumponexit=true,filename=recording.jfr,maxsize=1024m,maxage=1d,settings=profile,path-to-gc-roots=true -Xlog:gc:gc.log:utctime,uptime,tid,level:filecount=10,filesize=128m -XX:NativeMemoryTracking=detail -XX:+PreserveFramePointer'"

#
# GUIX
#

_guix_vars(){
    if [ -z "${GUIX_PREV_ENV}" ]; then
        export GUIX_PREV_ENV=($(env))
    fi
    if [ -z "${GUIX_MANIFEST_DIR}" ]; then
        export GUIX_MANIFEST_DIR="${XDG_CONFIG_DIR:-$HOME/.config}/guix-manifests"
    fi
    if [ -z "${GUIX_EXTRA_PROFILES}" ]; then
        export GUIX_EXTRA_PROFILES="${XDG_DATA_HOME:-$HOME/.local/share}/guix-extra-profiles"
    fi
    if [ -z "${GUIX_ACTIVE_MANIFESTS+x}" ]; then
        export GUIX_ACTIVE_MANIFESTS=()
    fi
    if [ -z "${GUIX_LOCPATH}" ]; then
        export GUIX_LOCPATH="${HOME}/.guix-profile/lib/locale"
    fi
}
_guix_list_manifests(){
    echo "The following manifests are available:\ndefault"
    for manifest in "${GUIX_MANIFEST_DIR}"/*.scm; do
        local name=$(basename "${manifest%.*}")
        echo "${name}"
    done
}
_guix_install_profile(){
    local arg="${1}"
    local profile="${GUIX_EXTRA_PROFILES}/${arg}/${arg}"
    if [ "${arg}" != "default" ] &&
       [ ! -d "${profile}" ] &&
       [ -f "${GUIX_MANIFEST_DIR}/${arg}.scm" ]; then
        mkdir -p "${GUIX_EXTRA_PROFILES}/${arg}"
        guix package -m "${GUIX_MANIFEST_DIR}/${arg}.scm" -p "${profile}"
    fi
}
_guix_update_profile(){
    local arg="${1}"
    local profile="${GUIX_EXTRA_PROFILES}/${arg}/${arg}"
    if [ "${arg}" = "default" ];then
        guix pull
        guix package -u
    elif [ -f "${GUIX_MANIFEST_DIR}/${arg}.scm" ] &&
         [ -d "${profile}" ]; then
         guix package -m "${GUIX_MANIFEST_DIR}/${arg}.scm" -p "${profile}"
    else
        _guix_install_profile "${arg}"
    fi
}
_guix_deactivate_profile(){
    local arg="${1}"
    local ref="GUIX_PREV_ENV_${arg}"
    if [ ! -z "${(P)ref}" ]; then # the prev env exists # TODO: indirect variable expansion portable
        for entry in $(echo "${(P)ref}"); do # unset vars of profile # TODO: indirect variable expansion portable
            if [[ "${entry%%=*}" != GUIX_PREV_ENV.* ]] &&
               [ "${entry%%=*}" != "GUIX_ACTIVE_MANIFESTS" ] ;then
                unset "${entry%%=*}"
            fi
        done
        unset "GUIX_PREV_ENV_${arg}"
        for entry in $(echo "${GUIX_PREV_ENV}"); do # restore init env
            export "${entry%%=*}"="${entry#*=}"
        done
        # active manifests again
        for mani in $(echo "${GUIX_ACTIVE_MANIFESTS}"); do
            local profile="${GUIX_EXTRA_PROFILE}/${mani}/${mani}"
            if [ "${mani}" = "${arg}" ]; then # delete from active array
                export GUIX_ACTIVE_MANIFESTS=("${GUIX_ACTIVE_MANIFESTS[@]/$arg}")
            elif [ "${mani}" = "default" ]; then # load profiles
                [ -f "${HOME}"/.guix-profile/etc/profile ] && . "${HOME}"/.guix-profile/etc/profile
                [ -f "${HOME}"/.config/guix/current/etc/profile ] && . "${HOME}"/.config/guix/current/etc/profile
            elif [ -f "$profile"/etc/profile ]; then
                local GUIX_PROFILE="${profile}"
                . "${GUIX_PROFILE}"/etc/profile
            fi
        done
    fi
}
_guix_activate_profile(){
    local arg="${1}"
    for mani in $(echo "${GUIX_ACTIVE_MANIFESTS}"); do
        if [ "${mani}" = "${arg}" ]; then
            return # already active
        fi
    done
    _guix_install_profile "${arg}"
    local profile="${GUIX_EXTRA_PROFILES}/${arg}/${arg}"
    if [ "${arg}" = "default" ];then
        [ -f "${HOME}"/.guix-profile/etc/profile ] && . "${HOME}"/.guix-profile/etc/profile
        [ -f "${HOME}"/.config/guix/current/etc/profile ] && . "${HOME}"/.config/guix/current/etc/profile
        local stash="${GUIX_PREV_ENV}" # hide prev envs from being saved
        unset GUIX_PREV_ENV
        for mani in $(echo "${GUIX_ACTIVE_MANIFESTS}"); do
            local ref="GUIX_PREV_ENV_${mani}"
            local "stash_${mani}"="${(P)ref}" # TODO: indirect variable expansion portable
            unset "GUIX_PREV_ENV_${mani}"
        done
        local prev=($(env)) # save profiles env
        export "GUIX_PREV_ENV_${arg}"="${prev}"
        export GUIX_PREV_ENV="${stash}" # restore prev envs
        for mani in $(echo "${GUIX_ACTIVE_MANIFESTS}"); do
            local ref="stash_${mani}"
            export "GUIX_PREV_ENV_${mani}"="${(P)ref}" # TODO: indirect variable expansion portable
        done
        GUIX_ACTIVE_MANIFESTS+=($arg) # add to manifests
        export GUIX_ACTIVE_MANIFESTS
    elif [ -f "${profile}"/etc/profile ]; then
        local GUIX_PROFILE="${profile}"
        . "${GUIX_PROFILE}"/etc/profile
        local stash="${GUIX_PREV_ENV}" # hide prev env from being saved
        unset GUIX_PREV_ENV
        for mani in $(echo "${GUIX_ACTIVE_MANIFESTS}"); do
            local ref="GUIX_PREV_ENV_${mani}"
            local "stash_${mani}"="${(P)ref}" # TODO: indirect variable expansion portable
            unset "GUIX_PREV_ENV_${mani}"
        done
        local prev=($(env))
        export "GUIX_PREV_ENV_${arg}"="${prev}"
        export GUIX_PREV_ENV="${stash}" # restore prev env
        for mani in $(echo "${GUIX_ACTIVE_MANIFESTS}"); do
            local ref="stash_${mani}"
            export "GUIX_PREV_ENV_${mani}"="${(P)ref}" # TODO: indirect variable expansion portable
        done
        GUIX_ACTIVE_MANIFESTS+=($arg)
        export GUIX_ACTIVE_MANIFESTS
    fi
}
_guix_opts(){
    local help="
     Takes a list of manifest shortnames/commands

     GUIX_MANIFEST_DIR will be set to ${XDG_CONFIG_DIR:-$HOME/.config}/guix-manifests when not set
     GUIX_EXTRA_PROFILES will be set to ${XDG_DATA_HOME:-$HOME/.local/share}/guix-extra-profiles when not set
     GUIX_ACTIVE_MANIFESTS will be set to the profiles that are activated (in order)
     GUIX_PREV_ENV will be set to contents of env without profiles
     GUIX_PREV_ENV_shortname will be set to the contents of env with the profile

     The shortname is the manifest basename to use
     GUIX_MANIFEST_DIR/shortname.scm is the format of manifest search path
     Profiles for manifest will be stored under: GUIX_EXTRA_PROFILES/shortname/shortname

     The commands are activate, update, deactivate and list; activate is the default
     -a|--activate shortname -> sources/installs profile; appends to GUIX_ACTIVE_MANIFESTS
     -d|--deactivate shortname -> restore env before the profile was activated
     -u|--update shortname -> guix package upgrades profile
     -l|--list -> print the contents of GUIX_MANIFEST_DIR as shortnames
     -h|--help -> print this message
"
    _guix_vars
    while [ $# -gt 0 ]; do
        local arg="${1}"
        case "${arg}" in
            -a|--activate)
                _guix_activate_profile "${2}"
                shift 2
                ;;
            -d|--deactivate)
                _guix_deactivate_profile "${2}"
                shift 2
                ;;
            -h|--help)
                echo "${help}"
                shift
                ;;
            -l|--list)
                _guix_list_manifests
                shift
                ;;
            -u|--update)
                _guix_update_profile "${2}"
                shift 2
                ;;
            *)
                _guix_activate_profile "${1}"
                shift
                ;;
        esac
    done
}
alias guixProf=_guix_opts

#
# ZSH
#

_zsh_kbd_setup(){
    # key config
    [[ ! -f ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}} ]] && autoload -Uz zkbd && zkbd
    . ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}}
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
}
alias zsh_kbd_setup=_zsh_kbd_setup

_zsh_zinit_setup(){
    # Setup zinit
    local ZINIT_HOME="${ZDOTDIR:-$HOME}/.zinit"
    if [[ ! -d $ZINIT_HOME ]]; then
        # clone zinit
        mkdir ${ZINIT_HOME}
        chmod g-rwX ${ZINIT_HOME}
        git clone --depth 1 https://github.com/jamartin9/zinit.git ${ZINIT_HOME}/bin
        # load zinit for module/plugins
        . "${ZINIT_HOME}/bin/zinit.zsh"
        autoload -Uz _zinit
        (( ${+_comps} )) && _comps[zinit]=_zinit
        # build zinit module for compiling scripts/plugins and reports
        zinit module build
        # load module
        module_path+=( "${ZINIT_HOME}/bin/zmodules/Src" )
        zmodload zdharma/zplugin
    else
        # load module/zinit
        module_path+=( "${ZINIT_HOME}/bin/zmodules/Src" )
        zmodload zdharma/zplugin
        . "${ZINIT_HOME}/bin/zinit.zsh"
        autoload -Uz _zinit
        (( ${+_comps} )) && _comps[zinit]=_zinit
    fi
}
alias zsh_zinit_setup=_zsh_zinit_setup

_zsh_zinit_plugins(){
    # burst plugins
    #@zinit-scheduler burst

    # prompt theme
    typeset -g PROMPT_EOL_MARK=''
    zinit ice silent depth'1' atload"!. ${ZDOTDIR}/.p10k.zsh" nocd blockf #wait'!'
    zinit light romkatv/powerlevel10k

    # history
    zinit ice silent pick"history.zsh"
    zinit snippet OMZ::lib/history.zsh

    # completion
    zinit ice silent blockf wait'0' depth'1'
    zinit light zsh-users/zsh-completions

    # auto suggest
    zinit ice silent wait'0' atload'_zsh_autosuggest_start' cloneopts'-b develop --single-branch' depth'1' ver'develop'
    zinit light zsh-users/zsh-autosuggestions

    # syntax highlighting
    zinit ice silent wait'0' atinit'zicompinit; zicdreplay' depth'1'
    zinit light zdharma/fast-syntax-highlighting

    # zsh
    #zplugin ice id-as"zsh" \
        #        atclone"./.preconfig; CFLAGS=\"-I/usr/include -I/usr/local/include -g -O2 -Wall\" ./configure --prefix=\"$ZPFX\"" \
        #        atpull"%atclone" make"install"
    #zplugin load/update zsh
}
alias zsh_zinit_plugins=_zsh_zinit_plugins
