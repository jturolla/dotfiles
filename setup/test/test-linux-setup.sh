#!/bin/bash

set -euo pipefail

# Change to the project root directory
cd "$(dirname "$0")/../.."

# Create .setupconf from template if it doesn't exist
if [ ! -f setup/test/.setupconf ]; then
    echo "Creating .setupconf from template..."
    cp setup/.setupconf.template setup/test/.setupconf
fi

# Make sure setup scripts are executable
chmod +x setup/setup*.sh

echo "Building Docker image..."
docker build -t dotfiles-test -f setup/test/Dockerfile .

echo "Starting Docker container..."
docker run -it --rm dotfiles-test