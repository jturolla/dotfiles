#!/bin/bash

git_branch() {
  git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

git_commiter()  {
  if [ "$(git config user.email)" == "$GIT_WORK_EMAIL" ]; then
    echo "$(purple Nubank)"
    return
  fi

  echo "$(yellow Personal)"
}

git_prompt() {
  echo " \$(black $(git_branch)) $(black @) "
}

build_ps1() {
  local exit="$?"
  PS1="${green}\u${end} ${purple}\w${end}$(git_prompt)\$(git_commiter)"

  if [ $exit != 0 ]; then
    PS1+=" (-> ${red}${exit}${end})"
  fi

  PS1+=" $ "
}

manage_history() {
  shopt -s histappend
  history -a
  history -c
  history -r
}

prompt_command() {
  build_ps1
  manage_history
}

PROMPT_COMMAND=prompt_command
