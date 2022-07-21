export EDITOR='vim'
export CLICOLOR='auto'

export BASH_SILENCE_DEPRECATION_WARNING=1

export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33'
export LS_OPTS='--color=always'

export JAVA_HOME='/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home'
export JAVA_OPTS="-XX:-OmitStackTraceInFastThrow"

export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export GOROOT="/usr/local/opt/go/libexec"

export ANDROID_HOME="$HOME/Library/Android/sdk"

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="C"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_CURSES=1"

export KUBECTL_EXTERNAL_DIFF="dyff between --color=on --omit-header --set-exit-code --output human --no-table-style"
