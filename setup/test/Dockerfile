# Test environment for dotfiles setup
# This Dockerfile creates a test environment for running the dotfiles setup script
# in a clean Ubuntu environment.

FROM ubuntu:latest

# Build arguments
ARG TEST_USER=testuser
ARG TEST_USER_HOME=/home/testuser
ARG DOTFILES_PATH=/home/testuser/dev/dotfiles

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

# Switch to test user
USER ${TEST_USER}
WORKDIR ${TEST_USER_HOME}

# Create dotfiles directory structure
RUN mkdir -p ${DOTFILES_PATH}/setup

# Copy dotfiles and setup configuration
COPY --chown=${TEST_USER}:${TEST_USER} bash_profile vimrc gitconfig gitignore tmux.conf ssh_config aliases.sh colors.sh completion.sh env.sh history.sh path.sh prompt.sh gitconfig-template ${DOTFILES_PATH}/
COPY --chown=${TEST_USER}:${TEST_USER} setup/setup*.sh ${DOTFILES_PATH}/setup/
COPY --chown=${TEST_USER}:${TEST_USER} setup/test/.setupconf ${DOTFILES_PATH}/.setupconf

# Make scripts executable
USER root
RUN chmod +x ${DOTFILES_PATH}/setup/setup*.sh
USER ${TEST_USER}

# Run setup script and provide an interactive shell for inspection
CMD ["/bin/bash", "-c", "cd /home/testuser/dev/dotfiles && ./setup/setup.sh && bash"]