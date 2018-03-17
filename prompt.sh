#!/bin/bash

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

git_emoji()  {
  emoji="$(yellow Personal)"

  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    emoji="$(purple Nubank)"
  fi

  echo "$emoji "
}

git_prompt() {
  echo "\$(black $(git_branch)) $(black @) \$(git_emoji)"
}

export PS1="${green}\u${end} ${purple}\w${end} $(git_prompt) $ "

# bash shared history {
#  export HISTCONTROL=ignoredups:erasedups
#  shopt -s histappend
#  export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
# }
