This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal dotfiles for **macOS** and **Linux**: shell (bash/zsh), editors (Neovim, Helix, Vim), Git, SSH, tmux, and a scripted, idempotent bootstrap built on Homebrew (macOS) or apt (Linux).

The repo is its own home: files live here and are **symlinked** into `$HOME` by the setup scripts. Editing a tracked file in this repo immediately changes the live config once linked. The bootstrap is orchestrated by a `Makefile` + shell scripts under `setup/`, with shared helpers in `lib/setup-utils.sh` (colorful logging, `safe_symlink`, OS detection, package install). There is also optional tooling for a local LLM (Ollama) exposed through the `jullm` CLI.

Primary user/identity: Julio Turolla. Some files contain machine- and work-specific values (see [What NOT to Change](#what-not-to-change)).

## Plans

Design plans live in the top-level [`plans/`](./plans/) folder as numbered Markdown files (`NN-name.md`). See [`plans/README.md`](./plans/README.md) for the naming convention, frontmatter schema, and the plan index.

- Before implementing a non-trivial feature or subsystem, check `plans/` for a relevant plan; if none exists, add one (`NN-name.md`) and register it in `plans/README.md`.
- Keep the active plan updated as you build (status transitions, build-log notes).
- Plans capture design intent and decisions, not ephemeral task lists.

## Setup / Common Commands

Bootstrap requires a local `.setupconf` (gitignored) copied from the template:

```bash
cp setup/.setupconf.template .setupconf
# edit .setupconf (GIT_NAME, GIT_EMAIL, GITHUB_USER, SKIP_* flags, …)
make setup
```

`make setup` runs `setup/setup.sh`, which: validates `.setupconf` → checks prerequisites (creates `~/dev`, `~/.ssh`, `~/.env`, `tmp/`) → symlinks dotfiles (`setup-link.sh`) → runs platform setup (`setup-darwin.sh` or `setup-linux.sh`) → runs app setup (vim/git/fonts) → sets login shell to bash. Equivalent: `cd setup && ./setup.sh` (flags: `--skip-brew`, `--debug`, `--help`).

Frequently used targets (run `make help` for the full list):

| Command | Description |
|---------|-------------|
| `make setup` | Full bootstrap (link dotfiles, OS setup, apps, bash login shell) |
| `make setup-darwin` / `make setup-linux` | Platform-specific setup only |
| `cd setup && ./setup-link.sh` | (Re)create dotfile symlinks only |
| `make work-installation` | Install work-only `Brewfile.work` packages (macOS) |
| `make llm-install` then `jullm setup` | Install Ollama + pick/pull models, wire Cursor (see [docs/LLM.md](docs/LLM.md)) |
| `make setup-1password-ssh` | Configure SSH to use the 1Password agent (macOS) |
| `make enable-sudo-touchid` | Touch ID for sudo (run from a root shell: `sudo -s` first) |
| `make lint` | shellcheck all `*.sh` (auto-installs shellcheck) |
| `make lint-if-available` | shellcheck only when already installed |
| `make test-llm` | Python unit tests for the LLM catalog/picker |
| `make fix-permissions` | `chmod +x` shell scripts |
| `make unlink` | Remove dotfile symlinks (`unlink.sh`) |
| `make backup` / `make clean` | Tarball backup / reset `tmp/` |

CI (`.github/workflows/lint.yml`) runs `make lint` and `make test-llm` on push/PR to `main`/`master`.

## Repository Layout

```
dotfiles/
├── Makefile                # Entry point: setup, lint, work-installation, llm, …
├── bash_profile, zshrc     # Shell entrypoints → source the *.sh modules below
├── env.sh                  # Exports: EDITOR, locale, GPG, GOPRIVATE, SSH_AUTH_SOCK, …
├── path.sh                 # Builds $PATH (homebrew, $DOTFILES/bin, cargo, go, …)
├── prompt.sh               # Bash prompt (Powerline-style)
├── aliases.sh              # Aliases + functions (killport, reload!, gl, vim→nvim, …)
├── colors.sh               # Color helpers used by prompt + setup logging
├── completion.sh, history.sh
├── Brewfile, Brewfile.work # macOS Homebrew bundles (default + work-only)
├── gitconfig, gitignore    # Linked to ~/.gitconfig, ~/.gitignore
├── gitconfig-template      # Template variant
├── ssh_config              # Linked to ~/.ssh/config
├── tmux.conf, vimrc        # Linked to ~/.tmux.conf, ~/.vimrc
├── nvim/init.lua           # Neovim (lazy.nvim) → ~/.config/nvim/init.lua
├── helix/*.toml            # Helix config → ~/.config/helix/
├── iterm-colors/, nvim/    # Editor/terminal assets
├── after-setup-use-ssh-from-1password.sh  # Post-setup: SSH via 1Password agent
├── unlink.sh               # Remove created symlinks
├── setup/
│   ├── setup.sh            # Main orchestrator (all platforms)
│   ├── setup-config.sh     # Load/validate .setupconf, apply defaults
│   ├── setup-link.sh       # Symlink map repo → $HOME (with backups)
│   ├── setup-darwin.sh     # Homebrew + Brewfile + macOS defaults
│   ├── setup-linux.sh      # apt + Docker CE + AWS CLI v2 + k8s tools
│   ├── setup-git.sh, setup-vim.sh, setup-fonts.sh
│   ├── setup-llm.sh, llm-models.catalog
│   ├── change-shell-to-bash.sh, enable-sudo-touchid.sh
│   └── .setupconf.template
├── lib/
│   ├── setup-utils.sh      # Shared logging, safe_symlink, OS/pkg helpers
│   ├── llm.sh, llm_catalog.py, llm_select_fzf.py, cursor-sync.py
│   ├── git-completion.bash, kustomize-completion.bash, win-completion.bash  # vendored
│   └── docopts.sh, helpers/
├── bin/                    # On $PATH: jullm, llm, cursor-local, new-window, win, set-hostname
├── config/                 # cursor-models.json, llm.env (generated), llm.env.template
├── docs/                   # STRUCTURE.md, PACKAGES.md, LLM.md
├── tests/                  # Python tests (test_llm_catalog.py) + fixtures
├── plans/                  # Design plans (see Plans section)
├── .github/workflows/lint.yml
└── tmp/                    # Scratch (reset by make clean)
```

Authoritative symlink map: `setup/setup-link.sh` and [docs/STRUCTURE.md](docs/STRUCTURE.md). Linked targets include `bash_profile`→`~/.bash_profile`, `zshrc`→`~/.zshrc`, `vimrc`→`~/.vimrc`, `nvim/init.lua`→`~/.config/nvim/init.lua`, `helix/*.toml`→`~/.config/helix/`, `gitconfig`/`gitignore`→`~/.gitconfig`/`~/.gitignore`, `tmux.conf`→`~/.tmux.conf`, `ssh_config`→`~/.ssh/config`.

## Conventions

- **Shell scripts**: bash with `set -euo pipefail`. Source `lib/setup-utils.sh` for logging (`log_info`, `log_step`, `log_success`, `log_warning`, `log_error`, `fail_fast`) and helpers (`safe_symlink`, `ensure_dir`, `backup_file`, `is_macos`/`is_linux`, `command_exists`, `install_package`). Wrap a runnable `main` in the `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi` guard so scripts can be sourced or executed.
- **Idempotency**: setup steps must be safe to re-run. `safe_symlink` backs up any existing target as `<file>.backup.<timestamp>` before replacing it; new steps should follow the same backup-before-write pattern.
- **Symlink-first**: add new dotfiles to the `files_to_link` array in `setup/setup-link.sh` (and the validation list) rather than copying. Repo files are the source of truth.
- **New setup step**: create `setup/setup-foo.sh`, source `lib/setup-utils.sh`, and call it from `setup/setup.sh`; add a `make` target if user-facing.
- **Linting**: all `*.sh` must pass `make lint` (shellcheck). `setup/*`, `lib/*`, and `after-setup-*.sh` are linted with `-e SC1091`; keep this in mind for sourced paths. Run `make lint` before considering shell changes done.
- **Configuration**: user/machine settings go in `.setupconf` (gitignored), defaults in `setup/.setupconf.template` and `setup/setup-config.sh`. Don't hardcode values that belong in `.setupconf`.
- **Platform branching**: gate macOS-only vs Linux-only logic via `is_macos`/`is_linux` (or `$OSTYPE`), as done across `setup/` and the `Makefile`.
- **Packages**: macOS packages belong in `Brewfile` (everyone) or `Brewfile.work` (work-only); keep entries sorted/grouped consistently with the existing file. Linux packages live in the `packages=(...)` array in `setup-linux.sh`. Document notable packages in `docs/PACKAGES.md`.
- **Docs**: keep `README.md`, `docs/STRUCTURE.md`, and `docs/PACKAGES.md` in sync when you change the layout, setup flow, or package set.
- **Python** (LLM tooling): keep `make test-llm` green when touching `lib/llm_catalog.py`, `lib/llm_select_fzf.py`, or related files.

## What NOT to Change

- **Machine/identity-specific values** — change only with intent, not as drive-by edits:
  - `gitconfig`: real name/email, the `user.signingkey`, the 1Password `op-ssh-sign` program path, and the `nubank`/`nuinfra.net` URL rewrites.
  - `env.sh`: the hardcoded `SSH_AUTH_SOCK` (contains a specific username), `GOPRIVATE` (`github.com/nubank/*`, `golang.nuinfra.net/*`), and locale exports.
  - `bash_profile` / `zshrc`: tool-appended `PATH` lines (Ruby, LM Studio `lms`, Antigravity IDE) and the absolute user paths within them.
- **Local/secret/untracked files**: `.setupconf` (gitignored), `~/.env`, `~/.nurc`, and `config/llm.env` (generated). Edit the `.template` versions instead. Never commit secrets.
- **Vendored files**: `lib/git-completion.bash`, `lib/kustomize-completion.bash`, `lib/win-completion.bash` are upstream snapshots — refresh from source rather than hand-editing.
- **Generated/scratch**: `tmp/`, `backups/`, `__pycache__/`, `*.backup.<timestamp>` files left by `safe_symlink`.
- **Avoid running destructive or stateful commands** without being asked: `make setup`, `make unlink`, `chsh`/`change-shell-to-bash.sh`, `enable-sudo-touchid.sh`, `brew bundle`, and the symlink steps all mutate the real `$HOME`/system. Never run `git commit` or push unless explicitly requested.
