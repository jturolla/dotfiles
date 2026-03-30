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

alias aws-local="aws --profile local-minio --endpoint-url http://192.168.1.217:9000"
alias vim=nvim

killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port>" >&2
    return 1
  fi
  local pid
  pid=$(lsof -ti :"$1" 2>/dev/null)
  if [ -z "$pid" ]; then
    echo "No process found on port $1"
    return 1
  fi
  echo "$pid" | xargs kill -9
  echo "Killed process(es) $pid on port $1"
}
