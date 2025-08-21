#!/bin/bash

# Only run this file under Bash
if [ -n "$BASH_VERSION" ]; then
  # Load Homebrew bash-completion v2 only on Bash >= 4 (avoids errors on macOS bash 3.2)
  if [ "${BASH_VERSINFO:-0}" -ge 4 ] && [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    . "/opt/homebrew/etc/profile.d/bash_completion.sh"
  fi

  # Load custom completions
  . "$DOTFILES"/lib/git-completion.bash
  . "$DOTFILES"/lib/kustomize-completion.bash # gen by running: `kustomize completion bash`
  . "$DOTFILES"/lib/win-completion.bash

  # Enable programmable completion features (fallback for older setups)
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi

  # AWS CLI Completion
  complete -C '/opt/homebrew/bin/aws_completer' aws

  # Enable kubectl completion if available
  command -v kubectl >/dev/null 2>&1 && source <(kubectl completion bash)

  # Enable gh completion if available
  command -v gh >/dev/null 2>&1 && source <(gh completion -s bash)

  # Enable fzf completion and key bindings if available
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash
  if [ -f "/opt/homebrew/opt/fzf/shell/completion.bash" ]; then
    source "/opt/homebrew/opt/fzf/shell/completion.bash"
    source "/opt/homebrew/opt/fzf/shell/key-bindings.bash"
  fi
fi
