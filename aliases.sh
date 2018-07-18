alias l='ls -lah'

alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../'
alias .2='cd ../../'
alias ....='cd ../../../'
alias .3='cd ../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'

alias s='git status'
alias reload!="source ~/.bash_profile; echo 'Reloaded!'"

alias dnsflush='sudo killall -HUP mDNSResponder'

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias kms="nu k8s ctl --env staging --kcid monitoring -- "
alias kmp="nu k8s ctl --env prod --kcid monitoringb -- "

alias ks="nu k8s ctl --env staging -- "
alias kp="nu k8s ctl --env prod -- "

alias cm="git checkout master && git pull origin master && git checkout - && git rebase master"
alias cmm="git commit -am "

function nud {
  cd ~/dev/nu/$1
}

function switch-env {
  if [ "$1" == "work" ]; then
    git config --global user.name "$GIT_WORK_NAME"
    git config --global user.email "$GIT_WORK_EMAIL"
    echo "git changed to work."
  fi

  if [ "$1" == "personal" ]; then
    git config --global user.name "$GIT_PERSONAL_NAME"
    git config --global user.email "$GIT_PERSONAL_EMAIL"
    echo "git changed to personal."
  fi
}
