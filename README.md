# console — my zsh setup

A fast, portable zsh configuration I clone onto every Linux machine to get the
same shell everywhere — same prompt, same plugins, same keys — from one command.

**Stack**
- [zinit](https://github.com/zdharma-continuum/zinit) — plugin manager (auto-installs on first shell launch)
- [starship](https://starship.rs) — the prompt (config in [`starship/starship.toml`](starship/starship.toml))
- [fzf](https://github.com/junegunn/fzf) — fuzzy history (`Ctrl-R`), files (`Ctrl-T`), cd (`Alt-C`)
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smarter `cd` (`z <dir>`)
- [eza](https://github.com/eza-community/eza) + [bat](https://github.com/sharkdp/bat) — modern `ls` / `cat`
- [fd](https://github.com/sharkdp/fd) + [ripgrep](https://github.com/BurntSushi/ripgrep) — fast `find` / `grep` (fd also powers fzf's `Ctrl-T` / `Alt-C`)
- [delta](https://github.com/dandavison/delta) — syntax-highlighting pager for `git diff` / `log` / `show` (configured automatically)
- [tealdeer](https://github.com/tealdeer-rs/tealdeer) (`tldr`) — quick, offline command examples
- [lazygit](https://github.com/jesseduffield/lazygit) — full-screen terminal UI for git (alias `lg`; diffs rendered with delta)
- [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) — editor with a batteries-included config, vendored in [`nvim/`](nvim/)

**Plugins** (loaded via zinit **turbo mode** — async, after the prompt, for instant startup):
zsh-autosuggestions, zsh-completions, fzf-tab, fast-syntax-highlighting, zsh-history-substring-search,
[zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) (nudges you toward aliases you've defined).

## Back up your current shell first

`install.sh` already moves any existing `~/.zshrc` to
`~/.zshrc.pre-console.<timestamp>` before linking. For a full, restorable
snapshot (history, oh-my-zsh customizations, nvim/LazyVim, etc.), run this first.

Backups are kept under **`~/dotfiles-backups/`** — each snapshot is its own
timestamped folder (plus a `.tar.gz`) with a `RESTORE.md` inside:

```bash
BK=~/dotfiles-backups/shell-backup-$(date +%Y%m%d-%H%M%S); mkdir -p "$BK"
cp -a ~/.zshrc ~/.zshenv ~/.zprofile ~/.zsh_history "$BK"/ 2>/dev/null
[ -d ~/.oh-my-zsh/custom ] && cp -a ~/.oh-my-zsh/custom "$BK"/omz-custom
[ -d ~/.config/nvim ]      && cp -a ~/.config/nvim     "$BK"/nvim
tar czf "$BK.tar.gz" -C ~/dotfiles-backups "$(basename "$BK")" && echo "Backup: $BK.tar.gz"
```

Restore it any time with:

```bash
cp -a "$BK"/.zshrc ~/.zshrc && exec zsh    # $BK = the folder printed above
```

## Install on a new machine

Only `git` and `curl` need to exist first — the script installs the rest.

```bash
git clone https://github.com/morandeirachema/zsh.git ~/code/console
cd ~/code/console
./install.sh
exec zsh
```

The clone location doesn't matter — `.zshrc` resolves its own path, so you can
keep the repo wherever you like.

The installer is **idempotent** (safe to re-run). It detects your package
manager (apt / dnf / pacman / zypper), installs missing tools, backs up any
existing `~/.zshrc` to `~/.zshrc.pre-console.<timestamp>`, then symlinks this
repo's config into place. The **first** new shell then auto-installs zinit and
the plugins (a one-time ~10s step).

### Options
```bash
./install.sh --minimal   # zsh + plugins + prompt only (skip extras, lazygit, nvim, font)
./install.sh --no-nvim   # don't install Neovim/LazyVim or touch ~/.config/nvim
./install.sh --no-font   # skip the Nerd Font download
./install.sh --no-chsh   # don't change the default login shell
```

## After installing
Set your terminal font to **JetBrainsMono Nerd Font** (installed by the script)
so the prompt icons render. In kitty: `font_family JetBrainsMono Nerd Font`.

## Keys & commands

| Key / command      | What it does                                        |
| ------------------ | --------------------------------------------------- |
| `Ctrl-R`           | fuzzy-search shell history (fzf)                    |
| `Ctrl-T`           | fuzzy-pick a file into the current command          |
| `Alt-C`            | fuzzy `cd` into a subdirectory                      |
| `Tab`              | fuzzy completion menu (fzf-tab)                     |
| `→` / `End`        | accept the greyed-out autosuggestion                |
| `↑` / `↓`          | history search matching what you've already typed   |
| `z <dir>`          | jump to a frequently-used directory (zoxide)        |
| `zi`               | pick a directory to jump to, interactively          |
| `tldr <cmd>`       | practical examples for a command (offline)          |
| `git diff`         | paged through delta — syntax-highlighted, `n`/`N` to navigate |
| `lg`               | open lazygit — the terminal git UI (see below)      |

Handy aliases (see [`zsh/aliases.zsh`](zsh/aliases.zsh)): `ll` / `la` / `lt`
(eza listings), `gs` / `gl` / `gd` (git), `reload` (restart the shell),
`please` (re-run the last command with sudo), `myip`, `ports`.

## What the plugins do

| Plugin | What you get |
| ------ | ------------ |
| **zsh-autosuggestions** | As you type, greys out the rest of a matching past command — press `→` / `End` to accept it, or `Ctrl-→` to accept one word. |
| **fast-syntax-highlighting** | Colors the command line live: valid commands in green, unknown ones in red, quotes and paths highlighted — so you catch typos *before* pressing Enter. |
| **fzf-tab** | Replaces the plain `Tab` menu with a fuzzy [fzf](https://github.com/junegunn/fzf) selector — start typing to filter matches, with a directory preview when completing `cd`. |
| **zsh-history-substring-search** | Type a fragment of an old command, then `↑` / `↓` (or `Ctrl-P` / `Ctrl-N`) cycles through only the history entries that contain it. |
| **zsh-completions** | A large bundle of extra `Tab`-completion definitions for tools that don't ship their own. |
| **zsh-you-should-use** | After you run a command that has an alias you defined, reminds you the shorter alias exists — so the aliases actually stick. |

## Editor & git UI

### lazygit (`lg`)
A full-screen UI for git — stage, commit, branch, rebase, and resolve conflicts
without memorizing flags; diffs render through delta. Panels down the left
(**Status · Files · Branches · Commits · Stash**), diff on the right.

| Key | Does |
| --- | ---- |
| `?` | show every keybinding for the focused panel |
| `Tab` / `←` `→` | move between panels; `↑` `↓` (or `j`/`k`) within one |
| `Space` | context action — stage/unstage a file, checkout a branch, apply a stash |
| `Enter` | drill in — e.g. stage individual lines/hunks of a file |
| `c` / `A` | commit staged changes / amend the last commit |
| `p` / `P` / `f` | pull / push / fetch |
| `n` / `d` / `M` / `r` | (Branches) new / delete / merge / rebase |
| `s` / `x` / `q` | stash changes / command menu / quit |

### LazyVim (Neovim)
Leader key is **`Space`** — press it and pause to get a which-key menu of
everything. The first `nvim` launch installs all plugins; run `:LazyHealth` to
check the setup.

| Key | Does |
| --- | ---- |
| `<Space>` | which-key popup — discover every mapping |
| `<Space><Space>` | fuzzy-find files in the project |
| `<Space>/` | live-grep the whole project (ripgrep) |
| `<Space>e` | toggle the file explorer |
| `<Space>,` | switch between open buffers |
| `<Space>gg` | open lazygit inside Neovim |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `gd` · `gr` · `K` | go to definition · references · hover docs |
| `<Space>ca` · `<Space>cr` | code action · rename symbol |
| `<Space>l` · `<Space>cm` | Lazy (plugins) · Mason (LSP/tool installer) |
| `<Space>qq` | quit all |

Extend it by dropping files in [`nvim/lua/plugins/`](nvim/lua/plugins/) — full
docs at <https://www.lazyvim.org>.

## Per-machine overrides
Put anything machine-specific (secrets, local `PATH`, work aliases) in
`~/.zshrc.local` — it's sourced last and is **git-ignored**.

## Layout
```
.
├── install.sh              # idempotent bootstrap
├── zsh/
│   ├── .zshrc              # main config  ->  ~/.zshrc
│   └── aliases.zsh         # aliases (sourced by .zshrc)
├── starship/
│   └── starship.toml       # prompt       ->  ~/.config/starship.toml
├── nvim/                   # LazyVim config  ->  ~/.config/nvim
│   ├── init.lua
│   └── lua/{config,plugins}/…
├── lazygit/
│   └── config.yml          # lazygit config  ->  ~/.config/lazygit/config.yml
├── CLAUDE.md               # notes for AI assistants working in this repo
└── README.md
```

## Uninstall / revert
```bash
rm ~/.zshrc ~/.config/starship.toml ~/.config/nvim ~/.config/lazygit/config.yml
mv ~/.zshrc.pre-console.<timestamp> ~/.zshrc   # restore your previous one
exec zsh
```
