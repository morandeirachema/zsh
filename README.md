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

**Plugins** (loaded via zinit **turbo mode** — async, after the prompt, for instant startup):
zsh-autosuggestions, zsh-completions, fzf-tab, fast-syntax-highlighting, zsh-history-substring-search.

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
./install.sh --minimal   # zsh + plugins + prompt only (skip eza/bat/fd/rg/font)
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

Handy aliases (see [`zsh/aliases.zsh`](zsh/aliases.zsh)): `ll` / `la` / `lt`
(eza listings), `gs` / `gl` / `gd` (git), `reload` (restart the shell),
`please` (re-run the last command with sudo), `myip`, `ports`.

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
├── CLAUDE.md               # notes for AI assistants working in this repo
└── README.md
```

## Uninstall / revert
```bash
rm ~/.zshrc ~/.config/starship.toml
mv ~/.zshrc.pre-console.<timestamp> ~/.zshrc   # restore your previous one
exec zsh
```
