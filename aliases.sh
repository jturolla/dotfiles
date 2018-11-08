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

function nud {
  cd ~/dev/nu/$1
}

function switch-env {
  if [ "$1" == "work" ]; then
    git config --global user.name "$GIT_WORK_NAME"
    git config --global user.email "$GIT_WORK_EMAIL"
    ssh-add -d id_rsa_work
    ssh-add -d id_rsa_personal
    ssh-add $HOME/.ssh/id_rsa_work
    echo "git changed to work."
  fi

  if [ "$1" == "personal" ]; then
    git config --global user.name "$GIT_PERSONAL_NAME"
    git config --global user.email "$GIT_PERSONAL_EMAIL"
    ssh-add -d id_rsa_work
    ssh-add -d id_rsa_personal
    ssh-add $HOME/.ssh/id_rsa_personal
    echo "git changed to personal."
  fi
}

function gen-k8s-aliases {
  local prototype=$1
  alias s${prototype}="nu k8s ctl $prototype  --"
  alias ${prototype}="nu k8s ctl $prototype --env prod --"
}

for proto in s0 s1 s2 s3 s4 s5 s6 global monitoring
do
  gen-k8s-aliases $proto
done

function m() {
 nu k8s ctl monitoring --env prod --stack-id s -- $* -n monitoring
}

function sm() {
  nu k8s ctl monitoring --env staging -- $* -n monitoring
}

function k8s {
  readonly env=$1
  for proto in s1 s2 s3 s4 s5 s6 monitoring
  do
    nu k8s ctl $proto --env prod -- $* | while read line; do
      if [[ "$line" =~ .*NAME.* ]]; then continue; fi
      echo "$env/$proto/$line"
    done
  done
}
