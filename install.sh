#!/usr/bin/env bash
# ============================================================
#  install.sh — bootstrap chema's zsh console on any Linux box
#  Usage: ./install.sh [--minimal] [--no-font] [--no-chsh] [-y]
#    --minimal   only zsh + plugins + prompt (skip eza/bat/fd/rg/delta/tldr/font)
#    --no-font   don't download the Nerd Font
#    --no-chsh   don't change the default login shell
#    -y|--yes    non-interactive
# ============================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
NO_FONT=0; NO_CHSH=0; MINIMAL=0

for a in "$@"; do
  case "$a" in
    --no-font) NO_FONT=1;;
    --no-chsh) NO_CHSH=1;;
    --minimal) MINIMAL=1; NO_FONT=1;;
    -y|--yes)  : ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "unknown option: $a"; exit 1;;
  esac
done

c()    { printf '\033[%sm' "$1"; }
info() { printf '%s▶%s %s\n' "$(c '1;36')" "$(c 0)" "$*"; }
ok()   { printf '%s✓%s %s\n' "$(c '1;32')" "$(c 0)" "$*"; }
warn() { printf '%s!%s %s\n' "$(c '1;33')" "$(c 0)" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- package manager detection ---
PM=""
if   have apt-get; then PM=apt
elif have dnf;     then PM=dnf
elif have pacman;  then PM=pacman
elif have zypper;  then PM=zypper
fi
SUDO=""
[ "$(id -u)" -ne 0 ] && have sudo && SUDO="sudo"

pkg_install() {
  case "$PM" in
    apt)    $SUDO apt-get install -y "$@";;
    dnf)    $SUDO dnf install -y "$@";;
    pacman) $SUDO pacman -S --noconfirm "$@";;
    zypper) $SUDO zypper install -y "$@";;
    *) return 1;;
  esac
}

info "Repo:            $REPO_DIR"
info "Package manager: ${PM:-none detected}"

[ "$PM" = apt ] && { $SUDO apt-get update -y || true; }

# --- core ---
info "Installing core packages (zsh git curl unzip fontconfig)…"
pkg_install zsh git curl unzip fontconfig || warn "some core packages failed; continuing"

# --- fzf ---
have fzf || { info "Installing fzf…"; pkg_install fzf || warn "fzf failed"; }

# --- bat ---
if ! have bat && ! have batcat; then
  info "Installing bat…"; pkg_install bat || warn "bat failed"
fi

# --- fd (find) — Debian/Ubuntu package is 'fd-find', binary 'fdfind' ---
if ! have fd && ! have fdfind; then
  info "Installing fd…"; pkg_install fd-find || pkg_install fd || warn "fd failed"
fi

# --- ripgrep (rg) — fast grep ---
have rg || { info "Installing ripgrep…"; pkg_install ripgrep || warn "ripgrep failed"; }

# --- extras (skipped by --minimal) ---
if [ "$MINIMAL" -eq 0 ]; then
  # git-delta — syntax-highlighting pager for git diff/log/show
  if ! have delta; then
    info "Installing git-delta…"
    pkg_install git-delta || warn "git-delta not in your repos — see https://github.com/dandavison/delta/releases"
  fi
  # tealdeer (tldr) — simplified, offline command examples
  if ! have tldr; then
    info "Installing tealdeer (tldr)…"
    pkg_install tealdeer || warn "tealdeer failed — see https://github.com/tealdeer-rs/tealdeer"
  fi
  have tldr && tldr --update >/dev/null 2>&1 || true
fi

# --- eza (skip in --minimal) ---
if [ "$MINIMAL" -eq 0 ] && ! have eza; then
  info "Installing eza…"
  pkg_install eza || warn "eza not in your repos — see https://github.com/eza-community/eza"
fi

# --- starship (user-local, no sudo) — https://starship.rs ---
if ! have starship; then
  info "Installing starship…"
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" \
    || warn "starship install failed"
fi

# --- zoxide (user-local) — https://github.com/ajeetdsouza/zoxide ---
if ! have zoxide; then
  info "Installing zoxide…"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh \
    || warn "zoxide install failed"
fi

# --- Nerd Font — https://github.com/ryanoasis/nerd-fonts ---
if [ "$NO_FONT" -eq 0 ]; then
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    info "Installing JetBrainsMono Nerd Font…"
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    mkdir -p "$FONT_DIR"; tmp="$(mktemp -d)"
    if curl -sSfL -o "$tmp/JBM.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip; then
      unzip -oq "$tmp/JBM.zip" -d "$FONT_DIR"
      fc-cache -f >/dev/null 2>&1 || true
      ok "Font installed — set your terminal font to 'JetBrainsMono Nerd Font'."
    else
      warn "font download failed; rerun with --no-font to skip"
    fi
    rm -rf "$tmp"
  else
    ok "Nerd Font already present"
  fi
fi

# --- symlinks (backs up any existing real file) ---
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if   [ -L "$dst" ]; then rm -f "$dst"
  elif [ -e "$dst" ]; then
    warn "backing up $dst -> $dst.pre-console.$STAMP"
    mv "$dst" "$dst.pre-console.$STAMP"
  fi
  ln -s "$src" "$dst"; ok "linked $dst"
}

info "Linking config…"
link "$REPO_DIR/zsh/.zshrc"              "$HOME/.zshrc"
link "$REPO_DIR/starship/starship.toml"  "$HOME/.config/starship.toml"

# --- point git at delta (idempotent: individual keys, safe to re-run) ---
if have delta; then
  info "Configuring git to use delta…"
  git config --global core.pager "delta"
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true          # n / N jump between diff sections
  git config --global delta.line-numbers true
  git config --global merge.conflictStyle zdiff3
  git config --global diff.colorMoved default
  ok "git diff now uses delta"
fi

# --- default shell ---
if [ "$NO_CHSH" -eq 0 ]; then
  ZSH_BIN="$(command -v zsh || true)"
  if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" != "$ZSH_BIN" ]; then
    info "Setting default shell to $ZSH_BIN…"
    chsh -s "$ZSH_BIN" || warn "chsh failed — run manually: chsh -s $ZSH_BIN"
  fi
fi

echo
ok   "Done!  Start your new shell with:  exec zsh"
info "First launch auto-installs zinit + plugins (one-time, ~10s)."
