# Installed packages

What `make setup` installs on each platform. macOS uses [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) (`Brewfile` + optional `Brewfile.work`).

## macOS — default (`Brewfile`)

### Applications (casks)

| Package | What it does |
|---------|----------------|
| `1password` | Password manager and SSH agent integration |
| `1password-cli` | `op` CLI for vault access in scripts |
| `claude-code` | Terminal AI coding assistant (`claude` CLI) |
| `cursor` | Cursor IDE (VS Code–based editor with AI) |
| `iterm2` | Terminal emulator |
| `spotify` | Music streaming |
| `stats` | Open-source menu bar CPU/RAM/disk/network monitor |
| `utm` | Open-source QEMU VM app (Apple Silicon friendly) |
| `xbar` | Menu bar plugins from scripts (BitBar successor) |

### Containers & VMs

| Package | What it does |
|---------|----------------|
| `colima` | Lightweight Docker runtime on macOS (replaces Docker Desktop daemon) |
| `docker` | Docker CLI (`docker`, `docker compose`) — use with Colima |

After install: `colima start`

### AI & editor tooling

| Package | What it does |
|---------|----------------|
| `claude-code` | Anthropic Claude Code CLI — run `claude` in a repo after setup |
| `cursor` | Cursor app — sign in and open projects from the GUI |

Neovim also has Claude Code integration via `claudecode.nvim` in `nvim/init.lua`.

### Cloud & Kubernetes

| Package | What it does |
|---------|----------------|
| `awscli` | AWS CLI |
| `ko` | Build/push Go container images without a Dockerfile |
| `kubernetes-cli` | `kubectl` |
| `kubectx` | Switch kubectl context/namespace quickly |
| `kustomize` | Kubernetes YAML templating |

### Languages & runtimes

| Package | What it does |
|---------|----------------|
| `bash` | Modern Bash (login shell via `make change-shell-to-bash`) |
| `clojure` | Clojure runtime |
| `go` | Go toolchain |
| `node` | Node.js and npm |
| `openjdk` | Java JDK |
| `python` | Python 3 |
| `r` | R for statistics |
| `rust` | Rust and Cargo |

### Shell & CLI essentials

| Package | What it does |
|---------|----------------|
| `bash-completion@2` | Tab completion for Bash |
| `coreutils`, `findutils`, `gnu-sed`, `gnu-tar`, `grep`, … | GNU userland (often `g`-prefixed on macOS) |
| `diff-so-fancy` | Readable `git diff` |
| `fzf` | Fuzzy finder (history, files) |
| `jq`, `yq` | JSON and YAML processors |
| `ripgrep` | Fast `rg` code search |
| `tealdeer` | `tldr` — short command examples |
| `tmux` | Terminal multiplexer |
| `z` | Jump to frequent directories |

See `Brewfile` in the repo root for the full formula list (network tools, imagemagick, ledger, etc.).

## macOS — work only (`Brewfile.work`)

Run: `make work-installation`

| Package | What it does |
|---------|----------------|
| `aws-iam-authenticator` | EKS authentication for `kubectl` via IAM |
| `pinentry-mac` | macOS GUI for GnuPG passphrase entry |
| `tektoncd-cli` | `tkn` for Tekton CI/CD on Kubernetes |

## Linux (`setup/setup-linux.sh`)

Ubuntu/Debian packages via `apt`, plus Docker CE, AWS CLI v2, `kubectl`, and `yq` (snap). See the `packages=(...)` array in `setup-linux.sh`.

**Cursor & Claude Code on Linux** (not in apt setup): install from vendor sites or:

```bash
# Claude Code (official installer)
curl -fsSL https://claude.ai/install.sh | bash

# Cursor — download .deb/.rpm from https://www.cursor.com/
```

## Optional extras

Add ad hoc formulas in `.setupconf`:

```bash
EXTRA_PACKAGES="some-formula"
```

`setup-darwin.sh` runs `brew install` for each token after the Brewfile.
