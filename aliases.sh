alias l='ls -lah'

alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

alias s='git status'
alias reload!="source ~/.bash_profile; echo 'Reloaded!'"

alias dnsflush='sudo killall -HUP mDNSResponder'

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias git-sign="git rebase --exec 'git commit --amend --no-edit -n -S' -i master"
alias pgit="GIT_SSH_COMMAND='ssh -i ~/.ssh/github.com-jturolla' git"
alias ramdisk="diskutil erasevolume HFS+ 'ephemeral-ram-disk' `hdiutil attach -nomount ram://8388608`"

function refresh-aws() {
  nu aws credentials refresh #--preferred-mfa-type 'token:software:totp'
}
