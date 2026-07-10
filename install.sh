#!/usr/bin/env bash
# ============================================================
#  install.sh — bootstrap chema's zsh console on any Linux or macOS box
#  Usage: ./install.sh [--minimal] [--server] [--no-nvim] [--no-font] [--no-chsh] [-y]
#    --minimal   only zsh + plugins + prompt (skip eza/bat/fd/rg/delta/tldr/lazygit/nvim/font)
#    --server    headless box: skip the Nerd Font (it lives on your client, not the server)
#    --no-nvim   don't install Neovim/LazyVim or touch ~/.config/nvim
#    --no-font   don't download the Nerd Font
#    --no-chsh   don't change the default login shell
#    -y|--yes    non-interactive
# ============================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
NO_FONT=0; NO_CHSH=0; MINIMAL=0; NO_NVIM=0

for a in "$@"; do
  case "$a" in
    --no-font) NO_FONT=1;;
    --server)  NO_FONT=1;;
    --no-chsh) NO_CHSH=1;;
    --no-nvim) NO_NVIM=1;;
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

# --- release-binary fallbacks (used when a tool isn't in the repos) ---
install_lazygit_release() {   # https://github.com/jesseduffield/lazygit
  local arch tmp ver
  case "$(uname -m)" in
    x86_64)  arch="Linux_x86_64" ;;
    aarch64) arch="Linux_arm64" ;;
    *) return 1 ;;
  esac
  tmp="$(mktemp -d)"
  ver="$(curl -sSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
         | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -1)"
  [ -n "$ver" ] || { rm -rf "$tmp"; return 1; }
  curl -sSfL -o "$tmp/lg.tgz" \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${ver}_${arch}.tar.gz" \
    || { rm -rf "$tmp"; return 1; }
  tar xzf "$tmp/lg.tgz" -C "$tmp" lazygit || { rm -rf "$tmp"; return 1; }
  mkdir -p "$HOME/.local/bin"; install "$tmp/lazygit" "$HOME/.local/bin/lazygit"
  rm -rf "$tmp"
}

install_neovim_release() {    # https://github.com/neovim/neovim/releases
  local asset tmp
  case "$(uname -m)" in
    x86_64)  asset="nvim-linux-x86_64" ;;
    aarch64) asset="nvim-linux-arm64" ;;
    *) return 1 ;;
  esac
  tmp="$(mktemp -d)"
  if ! curl -sSfL -o "$tmp/nvim.tgz" \
        "https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz"; then
    asset="nvim-linux64"   # legacy asset name (pre-2025 releases)
    curl -sSfL -o "$tmp/nvim.tgz" \
      "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" \
      || { rm -rf "$tmp"; return 1; }
  fi
  tar xzf "$tmp/nvim.tgz" -C "$tmp" || { rm -rf "$tmp"; return 1; }
  mkdir -p "$HOME/.local/bin"; rm -rf "$HOME/.local/nvim-dist"
  mv "$tmp/$asset" "$HOME/.local/nvim-dist"
  ln -sf "$HOME/.local/nvim-dist/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
}

nvim_recent() {               # true if an installed nvim is >= 0.9.0
  have nvim || return 1
  local v; v="$(nvim --version 2>/dev/null | sed -n '1s/.*v\([0-9][0-9.]*\).*/\1/p')"
  [ -n "$v" ] && [ "$(printf '%s\n0.9.0\n' "$v" | sort -V | head -1)" = "0.9.0" ]
}

# --- package manager detection ---
PM=""
if   have brew;    then PM=brew        # macOS (or Linuxbrew)
elif have apt-get; then PM=apt
elif have dnf;     then PM=dnf
elif have pacman;  then PM=pacman
elif have zypper;  then PM=zypper
fi
SUDO=""
# Homebrew must NOT run under sudo; the native package managers need it.
[ "$PM" != brew ] && [ "$(id -u)" -ne 0 ] && have sudo && SUDO="sudo"

pkg_install() {
  case "$PM" in
    brew)   brew install "$@";;
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
info "Installing core packages…"
if [ "$PM" = brew ]; then
  pkg_install zsh git curl || warn "some core packages failed; continuing"
else
  pkg_install zsh git curl unzip fontconfig || warn "some core packages failed; continuing"
fi

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
  # lazygit — terminal UI for git
  if ! have lazygit; then
    info "Installing lazygit…"
    pkg_install lazygit || install_lazygit_release \
      || warn "lazygit failed — see https://github.com/jesseduffield/lazygit/releases"
  fi
fi

# --- Neovim + LazyVim (skipped by --minimal / --no-nvim) ---
if [ "$MINIMAL" -eq 0 ] && [ "$NO_NVIM" -eq 0 ]; then
  info "Setting up Neovim + LazyVim…"
  if [ "$PM" = brew ]; then
    have cc || warn "run 'xcode-select --install' for a C compiler (nvim treesitter/telescope)"
    nvim_recent || pkg_install neovim || warn "neovim install failed — try: brew install neovim"
  else
    pkg_install gcc make || warn "build tools (gcc/make) failed — some nvim plugins need them"
    if ! nvim_recent; then
      info "Installing a recent Neovim (LazyVim needs >= 0.9)…"
      install_neovim_release || warn "neovim install failed — see https://github.com/neovim/neovim/releases"
    fi
  fi
fi

# --- eza (skip in --minimal) ---
if [ "$MINIMAL" -eq 0 ] && ! have eza; then
  info "Installing eza…"
  pkg_install eza || warn "eza not in your repos — see https://github.com/eza-community/eza"
fi

# --- starship — prefer a signed distro/brew package; fall back to the
#     official installer only when it isn't packaged.  https://starship.rs
if ! have starship; then
  info "Installing starship…"
  pkg_install starship || {
    warn "starship not packaged here — using the official installer (curl | sh)"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" \
      || warn "starship install failed"
  }
fi

# --- zoxide — prefer a packaged version; official installer as fallback.
#     https://github.com/ajeetdsouza/zoxide
if ! have zoxide; then
  info "Installing zoxide…"
  pkg_install zoxide || {
    warn "zoxide not packaged here — using the official installer (curl | sh)"
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh \
      || warn "zoxide install failed"
  }
fi

# --- Nerd Font — https://github.com/ryanoasis/nerd-fonts ---
if [ "$NO_FONT" -eq 0 ]; then
  if [ "$PM" = brew ]; then
    info "Installing JetBrainsMono Nerd Font (cask)…"
    brew install --cask font-jetbrains-mono-nerd-font \
      && ok "Font installed — set your terminal font to 'JetBrainsMono Nerd Font'." \
      || warn "font cask failed; rerun with --no-font to skip"
  elif ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
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

# lazygit config (symlink the file only, so lazygit's own state.yml stays local)
[ "$MINIMAL" -eq 0 ] && link "$REPO_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

# Neovim / LazyVim config (whole dir; lazy-lock.json lands in the repo for version pinning)
if [ "$MINIMAL" -eq 0 ] && [ "$NO_NVIM" -eq 0 ]; then
  link "$REPO_DIR/nvim" "$HOME/.config/nvim"
fi

# --- point git at delta via an include (non-destructive & revertible: your
#     existing ~/.gitconfig keys are untouched; drop the include to undo) ---
if have delta; then
  info "Configuring git to use delta…"
  frag="$REPO_DIR/git/delta.gitconfig"
  if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$frag"; then
    git config --global --add include.path "$frag"
  fi
  ok "git uses delta (undo: git config --global --unset-all include.path '$frag')"
fi

# --- default shell (skip if the login shell is already some zsh) ---
if [ "$NO_CHSH" -eq 0 ]; then
  ZSH_BIN="$(command -v zsh || true)"
  case "${SHELL:-}" in
    */zsh) : ;;   # already a zsh — don't force a different one (brew vs system)
    *)
      if [ -n "$ZSH_BIN" ]; then
        info "Setting default shell to $ZSH_BIN…"
        chsh -s "$ZSH_BIN" || warn "chsh failed — run manually: chsh -s $ZSH_BIN"
      fi
      ;;
  esac
fi

echo
ok   "Done!  Start your new shell with:  exec zsh"
info "First zsh launch auto-installs zinit + plugins (one-time, ~10s)."
[ "$MINIMAL" -eq 0 ] && [ "$NO_NVIM" -eq 0 ] && \
  info "First 'nvim' launch bootstraps LazyVim + its plugins (one-time)."
