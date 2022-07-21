#!/bin/bash

kubernetes_context() {
  kubectl config current-context
}

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

prompt_command() {
  local exit="$?"
  #PS1="\[${red}\]\u \[${lightblue}\]\w\[${blueb}\]\$(git_branch) |\[${greenb}\] \$(kubernetes_context)\[$end\]"
  PS1="\[${red}\]\u \[${lightblue}\]\w\[${blueb}\] | \[$end\]"

  if [ $exit != 0 ]; then
    PS1+=" (-> \[$red\]${exit}\[${end}\])"
  fi

  PS1+=" \[${blackb}\]$\[$end\] "
}

PROMPT_COMMAND=prompt_command
