# Dotfiles Makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Directories
SETUP_DIR := setup
LIB_DIR := lib

# Find all shell scripts
SHELL_SCRIPTS := $(shell find . -name "*.sh" -type f | grep -v ".git")

##@ Setup Commands

.PHONY: setup
setup: validate-env ## Run the complete dotfiles setup
	@echo -e "$(CYAN)🚀 Starting dotfiles setup...$(RESET)"
	@cd setup && ./setup.sh

.PHONY: setup-darwin
setup-darwin: validate-env ## Run macOS-specific setup only
	@echo -e "$(CYAN)🍎 Running macOS setup...$(RESET)"
	@cd setup && ./setup-darwin.sh

.PHONY: setup-linux
setup-linux: validate-env ## Run Linux-specific setup only
	@echo -e "$(CYAN)🐧 Running Linux setup...$(RESET)"
	@cd setup && ./setup-linux.sh

.PHONY: change-shell-to-bash
change-shell-to-bash: ## Set login shell to bash (runs chsh; may prompt for password)
	@echo -e "$(CYAN)🐚 Changing login shell to bash...$(RESET)"
	@cd setup && ./change-shell-to-bash.sh

.PHONY: work-installation
work-installation: ## Install work-only Homebrew packages from Brewfile.work (macOS)
	@if [[ "$$OSTYPE" != "darwin"* ]]; then \
		echo -e "$(RED)❌ work-installation is only available on macOS$(RESET)"; \
		exit 1; \
	fi
	@if ! command -v brew >/dev/null 2>&1; then \
		echo -e "$(RED)❌ Homebrew is required. Run make setup-darwin first.$(RESET)"; \
		exit 1; \
	fi
	@echo -e "$(CYAN)💼 Installing work packages from Brewfile.work...$(RESET)"
	@brew bundle --file="Brewfile.work" || { \
		echo -e "$(RED)❌ Some work packages failed to install$(RESET)"; \
		exit 1; \
	}
	@echo -e "$(GREEN)✅ Work packages installed$(RESET)"

.PHONY: setup-1password-ssh
setup-1password-ssh: ## Enable SSH from 1Password (run after main setup)
	@echo -e "$(CYAN)🔐 Setting up 1Password SSH integration...$(RESET)"
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		./after-setup-use-ssh-from-1password.sh; \
	else \
		echo -e "$(YELLOW)⚠️  1Password SSH setup is only available on macOS$(RESET)"; \
	fi

.PHONY: enable-sudo-touchid
enable-sudo-touchid: ## Enable Touch ID for sudo (must run from root shell: sudo -s)
	@echo -e "$(CYAN)👆 Enabling Touch ID for sudo...$(RESET)"
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		./setup/enable-sudo-touchid.sh; \
	else \
		echo -e "$(RED)❌ enable-sudo-touchid is only available on macOS$(RESET)"; \
		exit 1; \
	fi

.PHONY: revert-sudo-touchid disable-sudo-touchid
revert-sudo-touchid: ## Revert Touch ID sudo config (must run from root shell: sudo -s)
	@echo -e "$(CYAN)↩️  Reverting Touch ID for sudo...$(RESET)"
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		./setup/enable-sudo-touchid.sh --disable; \
	else \
		echo -e "$(RED)❌ revert-sudo-touchid is only available on macOS$(RESET)"; \
		exit 1; \
	fi

disable-sudo-touchid: revert-sudo-touchid ## Alias for revert-sudo-touchid

##@ Development Commands

.PHONY: lint
lint: ## Run shellcheck on all shell scripts (installs shellcheck if needed)
	@echo -e "$(YELLOW)🔍 Linting shell scripts...$(RESET)"
	@SHELLCHECK_CMD=""; \
	if command -v shellcheck >/dev/null 2>&1; then \
		SHELLCHECK_CMD="shellcheck"; \
	elif [ -x "/opt/homebrew/bin/shellcheck" ]; then \
		SHELLCHECK_CMD="/opt/homebrew/bin/shellcheck"; \
	elif [ -x "/usr/local/bin/shellcheck" ]; then \
		SHELLCHECK_CMD="/usr/local/bin/shellcheck"; \
	else \
		echo -e "$(YELLOW)📦 shellcheck not found, attempting to install...$(RESET)"; \
		$(MAKE) install-shellcheck || { \
			echo -e "$(RED)❌ shellcheck installation failed$(RESET)"; \
			echo -e "$(YELLOW)ℹ️  Please install shellcheck manually:$(RESET)"; \
			echo -e "$(YELLOW)   - macOS: brew install shellcheck$(RESET)"; \
			echo -e "$(YELLOW)   - Linux: sudo apt-get install shellcheck$(RESET)"; \
			exit 1; \
		}; \
		if command -v shellcheck >/dev/null 2>&1; then \
			SHELLCHECK_CMD="shellcheck"; \
		elif [ -x "/opt/homebrew/bin/shellcheck" ]; then \
			SHELLCHECK_CMD="/opt/homebrew/bin/shellcheck"; \
		elif [ -x "/usr/local/bin/shellcheck" ]; then \
			SHELLCHECK_CMD="/usr/local/bin/shellcheck"; \
		fi; \
	fi; \
	for script in $(SHELL_SCRIPTS); do \
		echo -e "$(CYAN)Checking $$script$(RESET)"; \
		if [[ "$$script" == ./setup/* ]] || [[ "$$script" == ./after-setup-use-ssh-from-1password.sh ]] || [[ "$$script" == ./lib/* ]]; then \
			$$SHELLCHECK_CMD -e SC1091 "$$script" || exit 1; \
		elif [[ "$$script" == ./completion.sh ]]; then \
			$$SHELLCHECK_CMD -e SC1091 -e SC1090 "$$script" || exit 1; \
		else \
			$$SHELLCHECK_CMD "$$script" || exit 1; \
		fi; \
	done
	@echo -e "$(GREEN)✅ All shell scripts passed linting$(RESET)"

.PHONY: lint-if-available
lint-if-available: ## Run shellcheck only if already installed
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo -e "$(YELLOW)🔍 Linting shell scripts...$(RESET)"; \
		for script in $(SHELL_SCRIPTS); do \
			echo -e "$(CYAN)Checking $$script$(RESET)"; \
			shellcheck "$$script" || exit 1; \
		done; \
		echo -e "$(GREEN)✅ All shell scripts passed linting$(RESET)"; \
	else \
		echo -e "$(YELLOW)⚠️  shellcheck not available, skipping linting$(RESET)"; \
		echo -e "$(YELLOW)ℹ️  Run 'make install-shellcheck' to enable linting$(RESET)"; \
	fi

.PHONY: fix-permissions
fix-permissions: ## Fix permissions on shell scripts
	@echo -e "$(YELLOW)🔧 Fixing script permissions...$(RESET)"
	@find . -name "*.sh" -type f -exec chmod +x {} \;
	@echo -e "$(GREEN)✅ Script permissions fixed$(RESET)"

.PHONY: validate-env
validate-env: ## Validate environment and dependencies
	@echo -e "$(YELLOW)🔍 Validating environment...$(RESET)"
	@if [ ! -f .setupconf ]; then \
		echo -e "$(RED)❌ .setupconf not found. Copy from setup/.setupconf.template$(RESET)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)✅ Environment validated$(RESET)"

##@ Installation Commands

.PHONY: install-shellcheck
install-shellcheck: ## Install shellcheck for linting
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo -e "$(GREEN)✅ shellcheck already installed$(RESET)"; \
		exit 0; \
	fi
	@echo -e "$(YELLOW)📦 Installing shellcheck...$(RESET)"
	@if command -v brew >/dev/null 2>&1; then \
		brew install shellcheck && echo -e "$(GREEN)✅ shellcheck installed via Homebrew$(RESET)"; \
	elif [ -x "/opt/homebrew/bin/brew" ]; then \
		/opt/homebrew/bin/brew install shellcheck && echo -e "$(GREEN)✅ shellcheck installed via Homebrew (Apple Silicon)$(RESET)"; \
	elif [ -x "/usr/local/bin/brew" ]; then \
		/usr/local/bin/brew install shellcheck && echo -e "$(GREEN)✅ shellcheck installed via Homebrew (Intel)$(RESET)"; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y shellcheck && echo -e "$(GREEN)✅ shellcheck installed via apt$(RESET)"; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y ShellCheck && echo -e "$(GREEN)✅ shellcheck installed via yum$(RESET)"; \
	elif command -v dnf >/dev/null 2>&1; then \
		sudo dnf install -y ShellCheck && echo -e "$(GREEN)✅ shellcheck installed via dnf$(RESET)"; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S --noconfirm shellcheck && echo -e "$(GREEN)✅ shellcheck installed via pacman$(RESET)"; \
	else \
		echo -e "$(RED)❌ No supported package manager found$(RESET)"; \
		echo -e "$(YELLOW)ℹ️  Please install shellcheck manually:$(RESET)"; \
		echo -e "$(YELLOW)   - Download from: https://github.com/koalaman/shellcheck$(RESET)"; \
		echo -e "$(YELLOW)   - Or use your system's package manager$(RESET)"; \
		exit 1; \
	fi

##@ Utility Commands

.PHONY: clean
clean: ## Clean temporary files and directories
	@echo -e "$(YELLOW)🧹 Cleaning temporary files...$(RESET)"
	@rm -rf tmp/
	@mkdir -p tmp
	@echo -e "$(GREEN)✅ Cleanup complete$(RESET)"

.PHONY: backup
backup: ## Create a backup of current configurations
	@echo -e "$(YELLOW)💾 Creating backup...$(RESET)"
	@mkdir -p backups
	@tar -czf "backups/dotfiles-backup-$$(date +%Y%m%d-%H%M%S).tar.gz" \
		--exclude='.git' \
		--exclude='tmp' \
		--exclude='backups' \
		.
	@echo -e "$(GREEN)✅ Backup created in backups/$(RESET)"

.PHONY: unlink
unlink: ## Unlink all dotfiles
	@echo -e "$(RED)⚠️  Unlinking dotfiles...$(RESET)"
	@./unlink.sh

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST) 