#!/bin/bash

export HISTSIZE=5000000
export HISTFILESIZE=100000000
export HISTCONTROL=ignoredups:erasedups
export HISTFILE=~/.bash_history

shopt -s histappend

export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r;"
