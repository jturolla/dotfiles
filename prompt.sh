#!/bin/bash

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

user="\[$COLOR_YELLOW\]\u"
path="\[$COLOR_LIGHT_CYAN\]\w"
git="\[$COLOR_LIGHT_PURPLE\]\$(parse_git_branch)"
prompt="\[$COLOR_NC\]\$ "

export PS1="$user $path $git $prompt" 
