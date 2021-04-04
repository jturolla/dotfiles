#!/bin/bash

git_branch() {
  git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

git_commiter()  {
  echo "as ${EMAIL}"
}

commiter_color() {
  echo -e "$blueb"
}

prompt_command() {
  local exit="$?"
  PS1="\[${red}\]\u \[${lightblue}\]\w\[${blue}\]\$(git_branch) \[${green}\]@ \[\$(commiter_color)\]\$(git_commiter)\[$end\]"

  if [ $exit != 0 ]; then
    PS1+=" (-> \[$red\]${exit}\[${end}\])"
  fi

  PS1+=" \[${blackb}\]$\[$end\] "
}

PROMPT_COMMAND=prompt_command
