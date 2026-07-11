#!/usr/bin/env bash
# tmux-sessionizer — fzf-pick a project directory and open/switch to a tmux
# session for it (one session per project). Inspired by ThePrimeagen's script.
#
# install.sh symlinks this to ~/.local/bin/tmux-sessionizer; tmux/tmux.conf
# binds it to `prefix + f`. It also runs standalone: outside tmux it creates
# and attaches the session; inside tmux it switches the client to it.
#
# Search roots come from $TMUX_SESSIONIZER_PATHS (space-separated) if set,
# otherwise the common project dirs below that actually exist. Override
# per-machine in ~/.zshrc.local, e.g.:
#     export TMUX_SESSIONIZER_PATHS="$HOME/code $HOME/work $HOME/.config"
set -euo pipefail

if ! command -v fzf >/dev/null 2>&1; then
  echo "tmux-sessionizer: fzf is required (install it or run ./install.sh)" >&2
  exit 1
fi

# --- search roots ---
roots=()
if [ -n "${TMUX_SESSIONIZER_PATHS:-}" ]; then
  # shellcheck disable=SC2206  # deliberate word-split on spaces
  roots=(${TMUX_SESSIONIZER_PATHS})
else
  for d in "$HOME/code" "$HOME/projects" "$HOME/src" "$HOME/work" "$HOME/dev"; do
    [ -d "$d" ] && roots+=("$d")
  done
  [ ${#roots[@]} -eq 0 ] && roots=("$HOME")
fi

# --- pick a directory (explicit arg wins, else fuzzy-find one level deep) ---
if [ "$#" -eq 1 ]; then
  selected="$1"
else
  if   command -v fd     >/dev/null 2>&1; then finder=(fd --max-depth 1 --type d . "${roots[@]}")
  elif command -v fdfind >/dev/null 2>&1; then finder=(fdfind --max-depth 1 --type d . "${roots[@]}")
  else finder=(find "${roots[@]}" -mindepth 1 -maxdepth 1 -type d); fi
  selected="$("${finder[@]}" 2>/dev/null | fzf --prompt='project> ' --preview 'ls -1 {}' || true)"
fi
[ -z "${selected:-}" ] && exit 0

# tmux session names can't contain '.' or ':' — sanitize.
name="$(basename "$selected" | tr '.:' '__')"

# Create the session (detached) if it doesn't already exist. `new-session -ds`
# starts a server when none is running, so this works from a bare terminal too —
# and skipping it when the session exists avoids a "duplicate session" error.
if ! tmux has-session -t="$name" 2>/dev/null; then
  tmux new-session -ds "$name" -c "$selected"
fi

# Attach from outside tmux, or switch the current client when already inside one.
if [ -z "${TMUX:-}" ]; then
  exec tmux attach -t "$name"
else
  exec tmux switch-client -t "$name"
fi
