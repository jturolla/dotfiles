#!/bin/bash

setup_fonts() {
    echo "Setting up fonts..."

    # Create temporary directory for fonts
    local tmp_fonts_dir="$DOTFILES/tmp/powerline-fonts"
    mkdir -p "$tmp_fonts_dir"

    # Clone powerline fonts repository
    if [ ! -d "$tmp_fonts_dir" ]; then
        echo "Downloading powerline fonts..."
        git clone https://github.com/powerline/fonts.git --depth=1 "$tmp_fonts_dir"
    fi

    # Install fonts
    echo "Installing powerline fonts..."
    (cd "$tmp_fonts_dir" && ./install.sh)

    # Cleanup
    echo "Cleaning up font installation files..."
    rm -rf "$tmp_fonts_dir"

    echo "Fonts installation complete!"
    echo "NOTE: Don't forget to set your terminal font to a Powerline font (e.g., 'Meslo LG M for Powerline')"
}

main() {
    setup_fonts
}

main