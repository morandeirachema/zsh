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

## P1 — do next
- **Supply-chain: pin & verify.** Pin the zinit clone to a tag and verify plugin
  integrity; pin tool versions (or record them) for reproducible rebuilds.
  Consider `zinit ice ver"..."` and checksum-verifying release-binary downloads
  (lazygit/neovim) instead of trusting the tarball blindly.
- **Air-gapped / offline mode.** A `--offline` path that skips every network
  fetch and a documented way to vendor zinit + plugins for locked-down hosts
  (many prod servers can't reach github.com).
- **Secrets hygiene doc + guardrails.** Document that space-prefixed commands are
  kept out of history (`HIST_IGNORE_SPACE` is on); add optional `ssh-agent` /
  `GPG_TTY` bootstrapping in a commented block; never echo secrets in the prompt.
- **CI in the repo.** GitHub Actions running `shellcheck` + `shfmt` on
  `install.sh`, a `zsh -n` / `bash -n` lint, and a container smoke-test that runs
  `./install.sh --server -y` on ubuntu/fedora/arch images.

## P2 — nice
- **tmux config** (`tmux/tmux.conf`, symlinked) — persistent sessions are core to
  sysadmin work over SSH; add sane defaults + a status line matching the prompt.
- **`jq` / `yq`** — near-essential for ops (JSON/YAML wrangling). Add to installer.
- **direnv** — per-project env/secret loading with an allowlist.
- **carapace** — unified completions for kubectl/aws/docker/terraform/gh, etc.
- **XDG layout** — move to `ZDOTDIR=~/.config/zsh` so `$HOME` stays clean.
- **Make kube/aws prompt segments gate-able** — a documented `detect_files`
  option for people who don't want them always on.

## P3 — later
- **Audit log** of what `install.sh` changed (packages, symlinks, gitconfig) to a
  timestamped file for change-management/review.
- **Uninstall script** that reverses symlinks + the gitconfig include cleanly.
- **1Password / Vault SSH-agent** integration notes for PAM workflows.
- **Per-host profiles** (`~/.zshrc.local` is the hook) — e.g. prod vs staging
  prompt accent color to reinforce "which environment".
