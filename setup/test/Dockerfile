# Test environment for dotfiles setup
# This Dockerfile creates a test environment for running the dotfiles setup script
# in a clean Ubuntu environment.

FROM ubuntu:latest

# Build arguments
ARG TEST_USER=testuser
ARG TEST_USER_HOME=/home/testuser

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    sudo \
    bash \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Create test user with sudo access
RUN useradd -m -s /bin/bash ${TEST_USER} && \
    echo "${TEST_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${TEST_USER}

# Create necessary directories
RUN mkdir -p ${TEST_USER_HOME}/dev && \
    mkdir -p ${TEST_USER_HOME}/.ssh && \
    chown -R ${TEST_USER}:${TEST_USER} ${TEST_USER_HOME}

# Switch to test user
USER ${TEST_USER}
WORKDIR ${TEST_USER_HOME}

# The dotfiles directory will be mounted at runtime
VOLUME ${TEST_USER_HOME}/dev/dotfiles

# Run setup script and provide an interactive shell
CMD ["/bin/bash", "-c", "cd ~/dev/dotfiles && ./setup/setup.sh && bash"]