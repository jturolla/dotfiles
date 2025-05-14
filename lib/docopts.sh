#!/bin/bash

DOCOPTS_VERSION="v0.6.3-rc2"
DOCOPTS_BIN_DIR="$HOME/.local/bin"

ensure_docopts() {
    if ! command -v docopts > /dev/null; then
        echo "Installing docopts..."
        mkdir -p "$DOCOPTS_BIN_DIR"

        case "$OSTYPE" in
            darwin*)
                DOCOPTS_URL="https://github.com/docopt/docopts/releases/download/${DOCOPTS_VERSION}/docopts_darwin_amd64"
                ;;
            linux*)
                DOCOPTS_URL="https://github.com/docopt/docopts/releases/download/${DOCOPTS_VERSION}/docopts_linux_amd64"
                ;;
            *)
                echo "Unsupported operating system: $OSTYPE"
                exit 1
                ;;
        esac

        # Download and install docopts
        if ! curl -sfL "$DOCOPTS_URL" -o "$DOCOPTS_BIN_DIR/docopts"; then
            echo "Failed to download docopts"
            exit 1
        fi

        chmod +x "$DOCOPTS_BIN_DIR/docopts"

        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$DOCOPTS_BIN_DIR:"* ]]; then
            export PATH="$DOCOPTS_BIN_DIR:$PATH"
        fi

        echo "docopts installed successfully at $DOCOPTS_BIN_DIR/docopts"
    fi
}