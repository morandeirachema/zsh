# ============================================================
#  aliases.zsh  —  sourced by .zshrc
#  Everything degrades gracefully if the tool isn't installed.
# ============================================================

# --- ls -> eza (https://github.com/eza-community/eza) ---
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto --git'
  alias la='eza -a  --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ll='ls -lah'
  alias la='ls -A'
  alias lt='ls -R'
fi

# --- cat -> bat (called 'batcat' on Debian/Ubuntu) ---
if command -v bat >/dev/null; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
fi

# --- fd (find) — binary is 'fdfind' on Debian/Ubuntu; also drives fzf ---
if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
  alias fd='fdfind'; _FD_BIN='fdfind'
elif command -v fd >/dev/null; then
  _FD_BIN='fd'
fi
if [[ -n "${_FD_BIN:-}" ]]; then
  # let fzf's Ctrl-T / Alt-C use fd (respects .gitignore, includes dotfiles)
  export FZF_DEFAULT_COMMAND="$_FD_BIN --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_FD_BIN --type d --hidden --follow --exclude .git"
fi
unset _FD_BIN

# --- rg (ripgrep) — fast recursive grep ---
command -v rg >/dev/null && alias rgi='rg -i'

# --- lazygit — terminal UI for git ---
command -v lazygit >/dev/null && alias lg='lazygit'

# --- neovim as the default editor ---
if command -v nvim >/dev/null; then
  alias vi='nvim'
  alias vim='nvim'
  alias v='nvim'
  export EDITOR='nvim'
  export VISUAL='nvim'
fi

# --- grep colors ---
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'

# --- navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias path='echo $PATH | tr ":" "\n"'

# --- git ---
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all'

# --- handy ---
alias reload='exec zsh'                 # reload shell after config changes
alias zshrc='${EDITOR:-nano} ~/.zshrc'
alias please='sudo $(fc -ln -1)'        # re-run last command with sudo
alias myip='curl -s https://ifconfig.me; echo'   # https://ifconfig.me
alias ports='ss -tulpn'
