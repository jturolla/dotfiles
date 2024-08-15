# Brew programs have precedence
export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:/opt/homebrew/sbin"

# Regular paths
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/usr/local"

# Dotfiles
export PATH="$PATH:$DOTFILES/bin"
export PATH="$PATH:$HOME/dev/nu/nucli"

if command -v go &> /dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi
