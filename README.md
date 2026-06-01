# Dotfiles

Personal dotfiles for **macOS** and **Linux**: shell, editors (Neovim, Helix, Vim), Git, SSH, and a scripted bootstrap with Homebrew or apt.

## Features

- Colorful, idempotent setup with `make setup`
- Modular scripts under `setup/` (run individually or all at once)
- macOS: [Brewfile](Brewfile) + optional [Brewfile.work](Brewfile.work) for work machines
- Linux: apt packages, Docker CE, AWS CLI v2, Kubernetes tools
- Symlinks with automatic backups of existing files
- `make lint` with shellcheck

## Quick start

```bash
git clone https://github.com/jturolla/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
cp setup/.setupconf.template .setupconf
# Edit .setupconf (git name, email, …)
make setup
```

Equivalent: `cd setup && ./setup.sh`

### After setup (macOS)

| Step | Command / action |
|------|------------------|
| New shell | Restart terminal (or `reload!` if already sourced) |
| Login shell | Setup runs `chsh` to bash; open a new session if prompted |
| Containers | `colima start` |
| Claude Code | `claude` in a project directory (sign in on first run) |
| Cursor | Open from Applications; sign in |
| Terminal font | iTerm2 → Powerline font (e.g. Meslo LG M for Powerline) |
| Work packages | `make work-installation` (EKS, Tekton, GnuPG pinentry) |
| 1Password SSH | `make setup-1password-ssh` (optional) |
| Touch ID sudo | `sudo -s` then `make enable-sudo-touchid` (requires root shell) |
| Neovim plugins | `nvim` then `:Lazy sync` |

## Documentation

| Doc | Contents |
|-----|----------|
| [docs/STRUCTURE.md](docs/STRUCTURE.md) | Repo layout, setup flow, symlink map |
| [docs/PACKAGES.md](docs/PACKAGES.md) | What each Brewfile / apt package does |

## Make targets

Run `make help` for the full list.

### Setup

| Target | Description |
|--------|-------------|
| `make setup` | Full bootstrap (link dotfiles, OS setup, apps, bash login shell) |
| `make setup-darwin` | macOS only (Homebrew + Brewfile) |
| `make setup-linux` | Linux only (apt + Docker + AWS CLI) |
| `make work-installation` | Work-only Brewfile (`aws-iam-authenticator`, Tekton, pinentry) |
| `make change-shell-to-bash` | Set login shell to bash (`chsh`) |
| `make setup-1password-ssh` | Use 1Password as SSH agent (macOS) |
| `make enable-sudo-touchid` | Touch ID for sudo — run from a root shell (`sudo -s` first) |
| `make revert-sudo-touchid` | Revert Touch ID sudo config — run from a root shell |
| `make disable-sudo-touchid` | Alias for `revert-sudo-touchid` |

### Development & maintenance

| Target | Description |
|--------|-------------|
| `make lint` | shellcheck all `*.sh` (installs shellcheck if needed) |
| `make lint-if-available` | shellcheck only when already installed |
| `make fix-permissions` | `chmod +x` on shell scripts |
| `make validate-env` | Check `.setupconf` exists |
| `make backup` | Tarball backup of the repo (excludes `.git`) |
| `make unlink` | Remove dotfile symlinks |
| `make clean` | Reset `tmp/` |

## Configuration (`.setupconf`)

Copy `setup/.setupconf.template` → `.setupconf`:

```bash
GIT_NAME="Your Name"
GIT_EMAIL="you@example.com"
GITHUB_USER="your-github-username"   # Linux SSH key hints

SKIP_BREW="false"                    # macOS: skip Homebrew entirely
EXTRA_PACKAGES="formula1 formula2"   # Extra brew installs after Brewfile

VIM_COLORSCHEME="monokai"
LOG_LEVEL="INFO"

SKIP_FONTS="false"
SKIP_VIM="false"
SKIP_GIT="false"
```

## What gets installed

### macOS (default `Brewfile`)

Installed by `setup-darwin.sh` via `brew bundle`.

**Editors & AI**

- **Cursor** — IDE (`cask "cursor"`)
- **Claude Code** — terminal assistant (`cask "claude-code"`, CLI: `claude`)
- iTerm2, Neovim/Vim config from this repo

**Dev & ops**

- Colima + Docker CLI, `kubectl`, `kustomize`, `kubectx`, AWS CLI, `gh`, Git, Go, Node, Python, Rust, …

**Apps**

- 1Password (+ CLI), Stats (menu bar), UTM (VMs), xbar, Spotify

Details: [docs/PACKAGES.md](docs/PACKAGES.md).

### macOS (work — `Brewfile.work`)

```bash
make work-installation
```

`aws-iam-authenticator`, `pinentry-mac`, `tektoncd-cli`.

### Linux

`setup-linux.sh`: build tools, shells, `fzf`, `ripgrep`, `kubectl`, Docker CE, AWS CLI v2, OpenJDK, and more. See [docs/PACKAGES.md](docs/PACKAGES.md) for Cursor/Claude on Linux (manual install).

### All platforms

- Symlinked shell, Git, SSH, tmux, Neovim, Helix
- Powerline fonts (`setup-fonts.sh`)
- Git config from template (`setup-git.sh`)

## Shell helpers

Loaded from `aliases.sh` (via `bash_profile` / `zshrc`):

| Command | Description |
|---------|-------------|
| `killport 3000` | Kill process(es) listening on a port |
| `reload!` | Re-source `~/.bash_profile` |
| `l` | `ls -lah` |
| `s` | `git status` |
| `vim` | Opens `nvim` |

Requires `DOTFILES=$HOME/dev/dotfiles` (set in `bash_profile`).

## Individual setup scripts

```bash
cd ~/dev/dotfiles/setup
./setup-link.sh        # Symlinks only
./setup-darwin.sh      # Homebrew + Brewfile
./setup-linux.sh       # apt + Docker + AWS
./setup-git.sh
./setup-vim.sh
./setup-fonts.sh
./change-shell-to-bash.sh
```

Flags for `./setup.sh`: `--skip-brew`, `--debug`, `--help`.

## Neovim

First launch installs plugins via lazy.nvim:

```bash
nvim
# or
nvim +'Lazy sync'
```

Claude in Neovim: leader keys under `<leader>a*` (see `nvim/init.lua`); requires Claude Code CLI and plugin deps.

## Customization

**New macOS package (everyone):** edit [Brewfile](Brewfile), run `brew bundle` or `make setup-darwin`.

**Work-only:** edit [Brewfile.work](Brewfile.work), run `make work-installation`.

**Linux:** add to `EXTRA_PACKAGES` in `.setupconf` or edit `setup-linux.sh`.

**New setup step:** add `setup/setup-foo.sh`, source `lib/setup-utils.sh`, call from `setup/setup.sh`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Scripts not executable | `make fix-permissions` |
| Missing `.setupconf` | `cp setup/.setupconf.template .setupconf` |
| Homebrew / bundle errors | `brew doctor`; run `make setup-darwin` again |
| Docker not running (macOS) | `colima start` |
| Port in use | `killport <port>` |
| Broken symlinks | Re-run `setup/setup-link.sh` |
| Lint | `make lint-if-available` |

Verbose setup: `cd setup && ./setup.sh --debug`

## Development

```bash
make install-shellcheck
make lint
```

CI runs lint on push (`.github/workflows/lint.yml`).

## License

MIT — see [LICENSE](LICENSE).
