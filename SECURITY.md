# Security posture

Notes for running this config on servers and privileged workstations. This is a
personal dotfiles repo, not a security product — but it tries not to make you
less safe. See [`ROADMAP.md`](ROADMAP.md) for what's still planned.

## Secrets & shell history
- **Keep secrets out of history:** commands typed with a **leading space** are
  never written to `~/.zsh_history` (`HIST_IGNORE_SPACE`). Prefix any command
  that contains a token/password with a space.
- **Never commit secrets.** Machine-specific values (tokens, private paths, work
  aliases) go in `~/.zshrc.local`, which is git-ignored and sourced **only if you
  own it** (guards against another account planting one). Start from
  [`zsh/zshrc.local.example`](zsh/zshrc.local.example).
- The prompt never prints secrets; it only shows `user@host`, git, and the
  Kubernetes/AWS *context names* (not credentials).

## Supply chain
- Tools install from your **distro/Homebrew package manager first**; the piped
  `curl | sh` installers (starship, zoxide) are a labelled fallback only.
- **Release binaries are checksum-verified**: lazygit, neovim, carapace and fabric
  downloads are SHA256-checked against their published checksums and refused on
  mismatch.
- **Pin zinit** for reproducible/air-gapped builds by exporting `ZINIT_PIN=<sha>`
  before the shell starts (e.g. in `~/.zshenv`).
- **Air-gapped:** run `./install.sh --offline` to skip every internet fetch
  (packages then come from your internal mirror). The one remaining network step
  is zinit cloning itself + plugins on first shell launch — pre-seed
  `~/.local/share/zinit` and the plugin repos on locked-down hosts.

## Completions & PATH
- `compinit` runs with `-i`: it keeps the security check and **skips** insecure
  (world/group-writable) completion directories instead of loading them — closing
  a completion-injection / privilege-escalation vector on shared hosts. It never
  runs with `-C` (which would bypass the check entirely).

## Git
- git-delta is wired in via an **`include.path`** into `~/.gitconfig` — additive
  and reversible; your existing git config is never rewritten. Undo with:
  `git config --global --unset-all include.path '<repo>/git/delta.gitconfig'`.

## Key agents (SSH / GPG)
- `GPG_TTY` is exported so `gpg` can prompt in your terminal (commit signing).
- **ssh-agent is left to your platform** (gnome-keyring, systemd, 1Password,
  Vault, etc.) to avoid spawning a conflicting one. To auto-start a plain agent
  when none is present, opt in via `~/.zshrc.local` — see the example file.
- **External agents (1Password / HashiCorp Vault / gpg-agent):** point
  `SSH_AUTH_SOCK` at the agent's socket from `~/.zshrc.local` — e.g. 1Password
  `export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"`. This keeps private keys in
  the vault/HSM (never on disk) — the PAM-friendly setup.

## Passwords & AI keys
- **`pass`** encrypts every secret to **your own GPG key** — nothing is installed
  with a key, and the store (`~/.password-store`) is yours to keep local or push to
  a **private** git remote. It complements the external SSH-agent setup above; use
  whichever fits the host. `GPG_TTY` is exported so `pass` can prompt for your
  passphrase in the terminal.
- **`fabric`** needs a provider API key. Run `fabric --setup` (it writes to
  `~/.config/fabric`, not the repo) and keep the key in `~/.zshrc.local`
  (git-ignored). Prefix any one-off `KEY=… fabric …` invocation with a leading
  space so it never lands in `~/.zsh_history` (`HIST_IGNORE_SPACE`). The binary is
  installed from a **SHA256-verified** GitHub release, same as lazygit/neovim.

## Undo
`./uninstall.sh` removes only the symlinks that point into this repo and the
git-delta include; it never deletes real files or packages. `install.sh` writes an
audit trail of everything it changed to `~/.local/state/console/install-<ts>.log`.

## Reporting
This repo has no formal disclosure process; open an issue on
<https://github.com/morandeirachema/zsh> for anything security-relevant.
