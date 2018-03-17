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

prompt_command() {
  local exit="$?"
  PS1="${green}\u${end} ${purple}\w${end}$(git_prompt)\$(git_commiter)"

  if [ $exit != 0 ]; then
    PS1+=" (-> ${red}${exit}${end})"
  fi

  PS1+=" $ "
}

PROMPT_COMMAND=prompt_command
