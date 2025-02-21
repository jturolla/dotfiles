#!/bin/bash

kubernetes_context() {
    if command -v kubectl &> /dev/null && context=$(kubectl config current-context 2> /dev/null); then
        if [[ "$context" == */* ]]; then
            context=${context##*/}
        fi
        echo "k8s: ${context} @ $(kubens -c)"
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
