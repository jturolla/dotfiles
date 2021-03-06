#!/bin/bash

git_branch() {
  git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

git_commiter()  {
  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    echo "Nubank(prod: $STACK_ID staging: $STAGING_STACK_ID)"
    return
  fi

  echo "Personal"
}

commiter_color() {
  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    echo -e "$purpleb"
    return
  fi

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
