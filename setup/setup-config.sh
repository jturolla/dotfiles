#!/bin/bash

load_configuration() {
    if [ -f .setupconf ]; then
        echo "Loading configuration from .setupconf..."
        source .setupconf
    else
        echo "No .setupconf found, using default values..."
    fi

    # Set default values for configuration variables
    GITHUB_USER=${GITHUB_USER:-jturolla}
}

main() {
    load_configuration
}

main