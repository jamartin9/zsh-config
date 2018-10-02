#!/usr/bin/env bash
#
# Cludge of aliases
#

_alias_ls(){
    if ! [ -x "$(command -v exa)" ]; then
        ls "$@"
    else
        exa "$@"
    fi
}
alias ls="_alias_ls"

_alias_cat(){
    if ! [ -x "$(command -v bat)" ]; then
        cat "$@"
    else
        bat "$@"
    fi
}
alias cat="bat"

_alias_grep(){
    if ! [ -x "$(command -v rg)" ]; then
        grep "$@"
    else
        rg "$@"
    fi
}
alias grep="rg"

_alias_find(){
    if ! [ -x "$(command -v fd)" ]; then
        find "$@"
    else
        fd "$@"
    fi
}
alias find="fd"

alias perfRecCmd="perf record -g --call-graph dwarf $1 | stackcollapse-perf | flamegraph > flame.svg"
alias perfScriptList="perf script -l"
alias perfReport="perf report -g"
alias perfTopSysCalls="perf top -e raw_syscalls:sys_enter -ns comm"
alias perfProbeList="perf probe -l"
alias perfSysCalls="perf stat -e raw_syscalls:sys_enter -I 1000 -a"
alias perfList="perf list"

alias javaListProps="java -server -XX:+PrintFlagsFinal -XX:+UnlockDiagnosticVMOptions --version"
alias javaToolOptions="export JAVA_TOOL_OPTIONS=-XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI -XX:+UseJVMCICompiler -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=heapdump.hprof -XX:StartFlightRecording=disk=true,dumponexit=true,filename=recording.jfr,maxsize=1024m,maxage=1d,settings=profile,path-to-gc-roots=true -Xlog:gc*=debug:file=gc.log:utctime,uptime,tid,level:filecount=10,filesize=128m -XX:NativeMemoryTracking=detail -XX:+PreserveFramePointer"
_jcmd_pid_help(){
    jcmd $(jps | grep $1 | awk '{print $1}') help
}
alias jcmdHelp="_jcmd_pid_help"

_wine_steam_path(){
    export WINEPATH="${STEAM_LIB}/common/${PROTON_VERSION}/dist/bin"
}
_steam_exports(){
    export STEAM_LIB="/storage/SteamLibrary/steamapps"
    export PROTON_VERSION="Proton\ 3.16"
    _wine_steam_path
}
_wine_steam_prefix(){
    export WINEPREFIX="${STEAM_LIB}/compatdata/${APP_ID}/pfx"
}
# Games
_divinity_original_sin_2(){
    # moves support tool to game and changes winecfg to win 10
    _steam_exports
    export APP_ID="435150"
    export GAME_NAME="Divinity\ Original\ Sin\ 2"
    _wine_steam_prefix

    # back up support tool
    mv "${STEAM_LIB}/common/${GAME_NAME}/DefEd/bin/SupportTool.exe" "${STEAM_LIB}/common/${GAME_NAME}/DefEd/bin/SupportTool.exe.bak"

    # move app to support tool
    cp "${STEAM_LIB}/common/${GAME_NAME}/DefEd/bin/EoCApp.exe" "${STEAM_LIB}/common/${GAME_NAME}/DefEd/bin/SupportTool.exe"

    # back up bin directory
    mv "${STEAM_LIB}/common/${GAME_NAME}/bin" "${STEAM_LIB}/common/${GAME_NAME}/bin.bak"

    # link the DefEd bin dir
    ln -s "${STEAM_LIB}/common/${GAME_NAME}/DefEd/bin" "${STEAM_LIB}/common/${GAME_NAME}/bin"

    # set to windows 10
    winecfg #winetricks --force xact
}
alias steamFixDivinity=_divinity_original_sin_2

# sets the core of jade empire for performance
_jade_empire(){
    pid=""
    while [[ "x$pid" == "x" ]]; do
        pid=`pidof JadeEmpire.exe`
    done
    mask=""
    while [[ "x$mask" == "x" ]]; do
        mask=`taskset -p "$pid" | grep "mask: 1"`
    done
    taskset -p 4 "$pid"
}
alias steamFixJadeEmpire=_jade_empire
