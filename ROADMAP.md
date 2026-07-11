# Roadmap — hardening for production sysadmin / DevOps / PAM use

This repo started as a personal desktop shell. This file tracks what was done to
make it safe and pleasant on servers and privileged workstations, and what's
still worth doing. Priority: **P1 = do next**, P2 = nice, P3 = later.

## ✅ Done (this pass)
- **compinit `-C` → `-i`** — no longer bypasses the insecure-completion-dir
  security check (completion-injection / privesc risk on shared hosts).
- **`~/.zshrc.local` is only sourced if owned by you** — blocks another account
  from planting a file that runs in your shell.
- **git-delta via `include.path`, not global-key overwrites** — additive and
  revertible; never rewrites an admin's existing `~/.gitconfig`.
- **Prefer signed packages over `curl | sh`** — starship/zoxide install from the
  distro/brew package first; the piped installer is only a labelled fallback.
- **Prompt tells you WHERE you are** — `user@host` shows over SSH (root in red),
  and Kubernetes context + AWS profile/region show when set. Prevents
  "ran it on the wrong box / wrong cluster / wrong account".
- **`--server`** flag skips the Nerd Font on headless boxes.
- **Cross-platform** installer (Linux apt/dnf/pacman/zypper + macOS Homebrew).
- **CI** — GitHub Actions: shellcheck + `bash -n`/`zsh -n` + toml/gitconfig/lua
  validation, and a smoke test that runs `./install.sh --minimal` in
  ubuntu/fedora/arch containers.
- **Supply-chain: verify downloads** — lazygit & neovim release binaries are now
  SHA256-checked against their published checksums before install; refuse on
  mismatch. `ZINIT_PIN` env var pins zinit to a commit/tag for reproducible builds.
- **Fixed** a latent bug (found by CI): `.zshrc` left `$?=1` with no
  `~/.zshrc.local`, which showed a false error on the first prompt.
- **`--offline` mode** — skips every internet fetch (curl installers, release
  binaries, font); packages come from your mirror.
- **Secrets hygiene** — `SECURITY.md` documents history/secret handling; `GPG_TTY`
  is set for signing; `zsh/zshrc.local.example` is a starter template; ssh-agent
  is left to the platform with an opt-in snippet.

## ✅ Done (P2 batch)
- **tmux config** (`tmux/tmux.conf`, symlinked) — mouse, vi copy, cwd-preserving
  splits, Catppuccin status bar matching the prompt.
- **`jq` / `yq`**, **direnv** (hooked in `.zshrc`), **carapace** (guarded
  completion hook) — added to the installer's extras.
- **Air-gapped plugin vendoring** — `scripts/vendor-plugins.sh` pre-seeds zinit +
  all plugins so `--offline` needs zero network on first launch.
- **XDG layout** — opt-in `--xdg` puts `.zshrc` under `ZDOTDIR=~/.config/zsh`.
- **Gate-able prompt** — `kubernetes`/`aws` segments ship with commented
  `detect_*` filters to scope them to infra dirs.

## P1 — last mile
- **Deeper pinning.** A full plugin lockfile (exact commit per plugin) and
  per-distro tool-version pins for byte-reproducible rebuilds. `ZINIT_PIN` +
  `scripts/vendor-plugins.sh` cover the common cases; this is what's left.

## P3 — later
- **Audit log** of what `install.sh` changed (packages, symlinks, gitconfig) to a
  timestamped file for change-management/review.
- **Uninstall script** that reverses symlinks + the gitconfig include cleanly.
- **1Password / Vault SSH-agent** integration notes for PAM workflows.
- **Per-host profiles** (`~/.zshrc.local` is the hook) — e.g. prod vs staging
  prompt accent color to reinforce "which environment".
