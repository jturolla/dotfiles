---
id: 01
title: Split public dotfiles and dotfiles-private
status: active
created: 2026-06-30
tags: [dotfiles, security]
---

# Public / private dotfiles split

## Goal

Keep editor and shell configs public; move git identity, SSH, LAN, homelab, and LLM tooling to **dotfiles-private** (private GitHub repo).

## Layout

| Public `dotfiles` | Private `dotfiles-private` |
|-------------------|----------------------------|
| vim, nvim, helix, tmux | `gitconfig`, `ssh_config` |
| bash_profile, zshrc (loads private) | `env-private.sh`, LAN aliases |
| Brewfile | Brewfile.work, jucli, jullm, jucode |
| setup-utils | setup-llm, homelab docs |

## Bootstrap

```bash
git clone git@github.com:jturolla/dotfiles.git ~/dev/dotfiles
git clone git@github.com:ruabage/dotfiles-private.git ~/dev/dotfiles-private
cd ~/dev/dotfiles && make setup
```

Public `make setup` auto-runs private setup when `~/dev/dotfiles-private` exists.
