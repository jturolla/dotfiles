#!/bin/bash

# Shell aliases for dotfiles

alias l='ls -lah'

alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

alias s='git status'
alias reload!="source ~/.bash_profile; echo 'Reloaded!'"

alias dnsflush='sudo killall -HUP mDNSResponder'
alias flushdns='sudo killall -HUP mDNSResponder'

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias vim=nvim

killport() {
  [ -z "$1" ] && { echo "Usage: killport <port>" >&2; return 1; }
  local p
  p=$(lsof -ti :"$1" 2>/dev/null) || true
  [ -z "$p" ] && { echo "No process found on port $1"; return 1; }
  echo "$p" | xargs kill -9 && echo "Killed process(es) $p on port $1"
}
