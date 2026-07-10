# ============================================================
#  ~/.zshrc  —  chema's zsh console
#  Managed as dotfiles; symlinked here from the repo.
#  Stack: zinit (plugins) + starship (prompt) + fzf + zoxide
# ============================================================

# --- Resolve the repo dir this file really lives in (follows the symlink) ---
ZDOTREPO="${${(%):-%x}:A:h}"

# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# --- Editor ---
export EDITOR="${EDITOR:-nano}"
export VISUAL="$EDITOR"

# ------------------------------------------------------------
#  History
# ------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across sessions
setopt INC_APPEND_HISTORY     # write immediately, not on exit
setopt EXTENDED_HISTORY       # record timestamps
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate entries
setopt HIST_IGNORE_SPACE      # ignore commands starting with a space
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # let me edit a !history expansion before running

# ------------------------------------------------------------
#  Sensible shell options
# ------------------------------------------------------------
setopt AUTO_CD                # `foo/` == `cd foo/`
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS   # allow # comments in interactive shell
setopt GLOB_DOTS              # include dotfiles in globs
setopt NO_BEEP
setopt COMPLETE_IN_WORD ALWAYS_TO_END

bindkey -e                    # emacs keybindings

# ------------------------------------------------------------
#  zinit — plugin manager (auto-installs on first run)
#  https://github.com/zdharma-continuum/zinit
# ------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  print -P "%F{cyan}▓▒░ Installing zinit (one time)…%f"
  command mkdir -p "$(dirname "$ZINIT_HOME")"
  command git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" \
    && print -P "%F{green}▓▒░ zinit installed.%f" \
    || print -P "%F{red}▓▒░ zinit clone failed.%f"
fi
source "$ZINIT_HOME/zinit.zsh"

# ------------------------------------------------------------
#  Plugins — zinit TURBO mode (loaded async, right after the
#  prompt appears → instant startup).
#  https://github.com/zdharma-continuum/zinit#turbo-mode-zsh--53
# ------------------------------------------------------------
# First wave: highlighting + completions + autosuggestions.
# compinit runs ONCE here via zicompinit (inside atinit), then the
# completion cache is replayed with zicdreplay — do not also call
# compinit synchronously elsewhere.
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  blockf \
      zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions

# Second wave: fzf-tab (must load after compinit) and
# history-substring-search. Its keys are bound in atload because in
# turbo mode the widget does not exist until the plugin is sourced.
zinit wait lucid light-mode for \
  Aloxaf/fzf-tab \
  atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down; bindkey "^P" history-substring-search-up; bindkey "^N" history-substring-search-down' \
      zsh-users/zsh-history-substring-search

# ------------------------------------------------------------
#  Completion styling (zstyles are read lazily at completion time)
# ------------------------------------------------------------

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
# fzf-tab previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'

# ------------------------------------------------------------
#  fzf — fuzzy finder (Ctrl-R history, Ctrl-T files, Alt-C cd)
#  https://github.com/junegunn/fzf
# ------------------------------------------------------------
if command -v fzf >/dev/null; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)                       # fzf >= 0.48
  else
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh   ]] && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi

# history-substring-search keys (Up/Down + Ctrl-P/N) are bound in the
# plugin's atload hook above — in turbo mode the widget only exists
# once the plugin has finished loading asynchronously.

# ------------------------------------------------------------
#  zoxide — smarter cd (`z foo`, `zi` interactive)
#  https://github.com/ajeetdsouza/zoxide
# ------------------------------------------------------------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ------------------------------------------------------------
#  starship — the prompt.  https://starship.rs
# ------------------------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"

# ------------------------------------------------------------
#  Aliases + per-machine overrides
# ------------------------------------------------------------
[[ -f "$ZDOTREPO/aliases.zsh" ]] && source "$ZDOTREPO/aliases.zsh"
# Machine-specific, NOT committed to the repo (secrets, local paths):
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
