export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/usr/local"
export PATH="$PATH:$DOTFILES/bin"
export PATH="$PATH:$HOME/dev/nu/nucli"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:/opt/homebrew/bin"
if command -v go &> /dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi
