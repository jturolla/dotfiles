#!/bin/bash

export EDITOR='vim'
export CLICOLOR='auto'

export BASH_SILENCE_DEPRECATION_WARNING=1

export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33'
export LS_OPTS='--color=always'

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export GPG_TTY="$(tty)"
export PINENTRY_USER_DATA="USE_CURSES=1"

export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1

export GOPATH="$(go env GOPATH)"
# Keep GOPRIVATE in the environment and (optionally) persist to Go toolchain
export GOPRIVATE='github.com/nubank/*,golang.nuinfra.net/*'
if command -v go >/dev/null 2>&1; then
    go env -w GOPRIVATE='github.com/nubank/*,golang.nuinfra.net/*' >/dev/null 2>&1 || true
fi

# Set 1Password SSH agent
export SSH_AUTH_SOCK="/Users/julio.turolla/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
