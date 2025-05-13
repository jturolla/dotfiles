#!/usr/bin/env bash

_win_completion() {
    local cur prev words cword
    _init_completion || return

    # If we are on the first argument
    if [ $cword -eq 1 ]; then
        # Get directories under $HOME/dev
        local dirs=$(find "$HOME/dev" -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | grep -v '^dev$')
        COMPREPLY=($(compgen -W "$dirs" -- "$cur"))
    fi
}

complete -F _win_completion win