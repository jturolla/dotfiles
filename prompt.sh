#!/bin/bash

kubernetes_context() {
  if command -v kubectl &> /dev/null && kubectl config current-context &> /dev/null; then
    echo " k8s: $(kubectl config current-context) @ $(kubens -c)"
  else
    echo ""
  fi
}

git_branch() {
  git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

prompt_command() {
  local exit="$?"
  PS1="\[${red}\]\u \[${lightblue}\]\w\[${blueb}\]\$(git_branch)\[${greenb}\]\$(kubernetes_context)\[$end\]"

  if [ $exit != 0 ]; then
    PS1+=" (-> \[$red\]${exit}\[${end}\])"
  fi

  PS1+=" \[${blackb}\]$\[$end\] "
}

PROMPT_COMMAND=prompt_command
