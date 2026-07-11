#!/usr/bin/env bash
# vendor-plugins.sh — pre-seed zinit + all plugins so a host can run OFFLINE.
# Run this on a CONNECTED machine; copy the result to air-gapped hosts, then
# run `./install.sh --offline` there (the plugins are already present, so the
# first zsh launch needs no network).
#
#   ./scripts/vendor-plugins.sh             # populate ~/.local/share/zinit
#   ./scripts/vendor-plugins.sh --tarball   # also produce a copyable bundle
set -euo pipefail

ZINIT_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"

# Keep this list in sync with the plugins loaded in zsh/.zshrc.
PLUGINS=(
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  Aloxaf/fzf-tab
  MichaelAquilina/zsh-you-should-use
  zsh-users/zsh-history-substring-search
)

clone() {  # clone <user/repo> <dest>
  local repo="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only -q || true
  else
    git clone --depth 1 "https://github.com/$repo.git" "$dest"
  fi
}

mkdir -p "$ZINIT_ROOT/plugins"
echo "▶ vendoring zinit into $ZINIT_ROOT"
clone "zdharma-continuum/zinit" "$ZINIT_ROOT/zinit.git"
for repo in "${PLUGINS[@]}"; do
  clone "$repo" "$ZINIT_ROOT/plugins/${repo/\//---}"   # zinit's user---repo layout
  echo "  ✓ $repo"
done

if [ "${1:-}" = "--tarball" ]; then
  out="$PWD/zinit-bundle.tar.gz"
  tar czf "$out" -C "$(dirname "$ZINIT_ROOT")" "$(basename "$ZINIT_ROOT")"
  echo "▶ bundle: $out"
  echo "  On the air-gapped host:  tar xzf zinit-bundle.tar.gz -C ~/.local/share/"
fi
echo "✓ Done. Air-gapped host: ensure ~/.local/share/zinit exists, then ./install.sh --offline"
