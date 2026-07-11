#!/usr/bin/env bash
# uninstall.sh — reverse what install.sh did: remove the symlinks it created and
# the git-delta include. Your ~/.zshrc.pre-console.<ts> backups are left in place.
# Does NOT uninstall packages (they may be used by other things).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
c()    { printf '\033[%sm' "$1"; }
info() { printf '%s▶%s %s\n' "$(c '1;36')" "$(c 0)" "$*"; }
ok()   { printf '%s✓%s %s\n' "$(c '1;32')" "$(c 0)" "$*"; }
warn() { printf '%s!%s %s\n' "$(c '1;33')" "$(c 0)" "$*"; }

# Remove a symlink only if it points inside THIS repo (never touch real files).
unlink_if_ours() {
  local dst="$1" tgt
  if [ -L "$dst" ]; then
    tgt="$(readlink -f "$dst" 2>/dev/null || true)"
    case "$tgt" in
      "$REPO_DIR"/*) rm -f "$dst"; ok "removed symlink $dst" ;;
      *) warn "left $dst (points outside this repo)" ;;
    esac
  elif [ -e "$dst" ]; then
    warn "left $dst (a real file, not our symlink)"
  fi
}

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
info "Removing console symlinks…"
unlink_if_ours "$HOME/.zshrc"
unlink_if_ours "$CONFIG/zsh/.zshrc"            # --xdg layout
unlink_if_ours "$CONFIG/starship.toml"
unlink_if_ours "$CONFIG/lazygit/config.yml"
unlink_if_ours "$CONFIG/tmux/tmux.conf"
unlink_if_ours "$CONFIG/nvim"

# Remove the git-delta include (leave the rest of ~/.gitconfig untouched).
frag="$REPO_DIR/git/delta.gitconfig"
if git config --global --get-all include.path 2>/dev/null | grep -qxF "$frag"; then
  git config --global --unset-all include.path "$frag" 2>/dev/null \
    && ok "removed git-delta include" \
    || warn "could not auto-remove the include — edit ~/.gitconfig by hand"
fi

echo
ok "Uninstalled. Packages and plugins were left in place."
info "Restore your previous shell (if you have a backup):"
# shellcheck disable=SC2012
ls -d "$HOME"/.zshrc.pre-console.* 2>/dev/null | sed 's/^/    mv & ~\/.zshrc/' || \
  info "  (no ~/.zshrc.pre-console.* backup found)"
info "Then reload:  exec zsh   (or restart your terminal)"
exit 0
