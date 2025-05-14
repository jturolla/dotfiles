#!/bin/bash

set -euo pipefail

# Change to the project root directory
cd "$(dirname "$0")/../.."

# Create .setupconf from template if it doesn't exist
if [ ! -f setup/test/.setupconf ]; then
    echo "Creating .setupconf from template..."
    cp setup/.setupconf.template setup/test/.setupconf
fi

# Build Docker image
echo "Building Docker image..."
docker build -t dotfiles-test -f setup/test/Dockerfile .

# Run Docker container with dotfiles mounted
echo "Starting Docker container..."
docker run -it --rm \
    -v "$(pwd):/home/testuser/dev/dotfiles" \
    -v "$(pwd)/setup/test/.setupconf:/home/testuser/dev/dotfiles/.setupconf" \
    dotfiles-test