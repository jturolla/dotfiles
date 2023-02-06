#!/bin/bash

kubernetes_context() {
  kubectl config current-context 2> /dev/null | gsed 's/.*\///'
}

git_branch() {
  git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

kube_ns() {
  kubens -c 2> /dev/null
}

prompt_command() {
  local exit="$?"
  PS1="\[${red}\]\u \[${lightblue}\]\w\[${blueb}\]\$(git_branch) |\[${greenb}\] \$(kubernetes_context) @ \$(kube_ns) \[$end\]"

  if [ $exit != 0 ]; then
    PS1+=" (-> \[$red\]${exit}\[${end}\])"
  fi

  PS1+=" \[${blackb}\]$\[$end\] "
}

PROMPT_COMMAND=prompt_command
