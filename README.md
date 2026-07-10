# console — my zsh setup

A fast, portable zsh configuration I clone onto every Linux machine.

**Stack**
- [zinit](https://github.com/zdharma-continuum/zinit) — plugin manager (auto-installs on first shell launch)
- [starship](https://starship.rs) — the prompt (config in [`starship/starship.toml`](starship/starship.toml))
- [fzf](https://github.com/junegunn/fzf) — fuzzy history (`Ctrl-R`), files (`Ctrl-T`), cd (`Alt-C`)
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smarter `cd` (`z <dir>`)
- [eza](https://github.com/eza-community/eza) + [bat](https://github.com/sharkdp/bat) — modern `ls` / `cat`

**Plugins:** zsh-autosuggestions, zsh-completions, fzf-tab, fast-syntax-highlighting, zsh-history-substring-search.

## Install on a new machine

```bash
git clone https://github.com/<your-username>/console.git ~/code/console
cd ~/code/console
./install.sh
exec zsh
```

The installer is **idempotent** — safe to re-run. It detects your package
manager (apt/dnf/pacman/zypper), installs missing tools, backs up any existing
`~/.zshrc` to `~/.zshrc.pre-console.<timestamp>`, then symlinks this repo's
config into place.

### Options
```
./install.sh --minimal   # zsh + plugins + prompt only (no eza/bat/font)
./install.sh --no-font    # skip the Nerd Font download
./install.sh --no-chsh    # don't change the default login shell
```

## After installing
Set your terminal font to **JetBrainsMono Nerd Font** (installed by the script)
so the prompt icons render. In kitty: `font_family JetBrainsMono Nerd Font`.

## Per-machine overrides
Put anything machine-specific (secrets, local `PATH`, work aliases) in
`~/.zshrc.local` — it's sourced last and is **git-ignored**.

## Layout
```
console/
├── install.sh              # idempotent bootstrap
├── zsh/
│   ├── .zshrc              # main config  -> ~/.zshrc
│   └── aliases.zsh         # aliases (sourced by .zshrc)
├── starship/
│   └── starship.toml       # prompt       -> ~/.config/starship.toml
└── README.md
```

## Uninstall / revert
```bash
rm ~/.zshrc ~/.config/starship.toml
mv ~/.zshrc.pre-console.<timestamp> ~/.zshrc   # restore your old one
exec zsh
```
