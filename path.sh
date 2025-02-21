# Initialize the variable
custom_paths=""

# Append each path to the variable
custom_paths="/opt/homebrew/bin:$custom_paths"
custom_paths="/opt/homebrew/sbin:$custom_paths"
custom_paths="/usr/local/sbin:$custom_paths"
custom_paths="/usr/local:$custom_paths"
custom_paths="$DOTFILES/bin:$custom_paths"
custom_paths="$HOME/dev/nu/nucli:$custom_paths"
custom_paths="$HOME/.cargo/bin:$custom_paths"

if command -v go &> /dev/null; then
    custom_paths="$(go env GOPATH)/bin:$custom_paths"
fi

# Postpend the variable in the final export statement
export PATH="$custom_paths:$PATH"
