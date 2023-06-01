# google cloud sdk

. $DOTFILES/lib/git-completion.bash
. $DOTFILES/lib/kustomize-completion.bash # gen by running: `kustomize completion bash`

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi
fi
