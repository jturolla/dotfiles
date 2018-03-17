#!/bin/bash

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

git_emoji()  {
  emoji="Personal"

  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    emoji="Nubank"
  fi

  echo "$emoji "
}

git_prompt() {
  echo "\[$COLOR_LIGHT_PURPLE\]\$(git_branch) @ \$(git_emoji)"
}

user="\[$COLOR_YELLOW\]\u"
path="\[$COLOR_LIGHT_CYAN\]\w"

export PS1="$user $path$(git_prompt) \[$COLOR_NC\]\$ "

# bash shared history {
#  export HISTCONTROL=ignoredups:erasedups
#  shopt -s histappend
#  export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
# }
