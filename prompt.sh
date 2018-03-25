#!/bin/bash

git_branch() {
  git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

git_commiter()  {
  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    echo "Nubank"
    return
  fi

  echo "Personal"
}

commiter_color() {
  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    echo -e "$purpleb"
    return
  fi

  echo -e "$yellowb"
}

prompt_command() {
  local exit="$?"
  PS1="\[${red}\]\u \[${black}\]\w\$(git_branch) \[${green}\]@ \[\$(commiter_color)\]\$(git_commiter)\[$end\]"

  if [ $exit != 0 ]; then
    PS1+=" (-> \[$red\]${exit}\[${end}\])"
  fi

  PS1+=" \[${blackb}\]$\[$end\] "
}

PROMPT_COMMAND=prompt_command
