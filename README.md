# console — a fast, portable zsh setup

One `git clone` gives every Linux **and** macOS box the same shell — same prompt,
same plugins, same keys — built to be safe and pleasant on servers and privileged
workstations, not just a desktop.

![CI](https://github.com/morandeirachema/zsh/actions/workflows/ci.yml/badge.svg)

```text
 󰕈    ~/code/console    main   !2 ?1                              2.4s   14:32:07
❯ ▏
```
> Over SSH the prompt grows a `user@host` badge (root in red) and your
> **Kubernetes**/**AWS** context — so you never run a command on the wrong box:
> ```text
> root@web-01  󰕈    /etc/nginx    main   ☸ prod:web    aws prod          14:32
> ❯ ▏
> ```

---

## Contents
- [Quick start](#quick-start)
- [What's inside](#whats-inside)
- [The prompt](#the-prompt)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Aliases](#aliases)
- [Plugins](#plugins)
- [Editor & git UI](#editor--git-ui)
- [tmux](#tmux)
- [Configuration & overrides](#configuration--overrides)
- [Security & production notes](#security--production-notes)
- [Updating](#updating)
- [Uninstall](#uninstall)
- [Repo layout](#repo-layout)

---

## Quick start

Only `git` + `curl` are needed up front; the installer adds the rest.

```bash
git clone https://github.com/morandeirachema/zsh.git ~/code/console
cd ~/code/console
./install.sh
exec zsh
```

The installer is **idempotent** (safe to re-run). It detects your package manager
(**Homebrew** on macOS, or apt / dnf / pacman / zypper on Linux), installs missing
tools, backs up any existing `~/.zshrc` to `~/.zshrc.pre-console.<timestamp>`, then
symlinks this repo's config into place. The clone location doesn't matter — the
config resolves its own path. First launch of `zsh` (and of `nvim`) auto-installs
plugins once.

**macOS:** also install [Homebrew](https://brew.sh) and — for Neovim's treesitter
— the Xcode CLT (`xcode-select --install`). The login shell is already zsh, so it
isn't changed.

### Flags

| Flag | Effect |
| ---- | ------ |
| `--minimal` | zsh + plugins + prompt only (skip eza/bat/fd/rg/delta/tldr/lazygit/nvim/font) |
| `--server` | headless box: skip the Nerd Font (it lives on your client) |
| `--offline` | air-gapped: no internet fetches — packages come from your mirror |
| `--xdg` | put `.zshrc` under `ZDOTDIR=~/.config/zsh` to keep `$HOME` tidy |
| `--no-nvim` | don't install Neovim/LazyVim or touch `~/.config/nvim` |
| `--no-font` | skip the Nerd Font download |
| `--no-chsh` | don't change the default login shell |
| `-y`, `--yes` | non-interactive |

After installing, set your terminal font to **JetBrainsMono Nerd Font** (installed
by the script) so the prompt icons render.

---

## What's inside

| Tool | Role |
| ---- | ---- |
| [zinit](https://github.com/zdharma-continuum/zinit) | plugin manager — **turbo mode** loads plugins async after the prompt for instant startup |
| [starship](https://starship.rs) | the prompt ([`starship/starship.toml`](starship/starship.toml)) |
| [fzf](https://github.com/junegunn/fzf) | fuzzy finder — history, files, cd |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | smarter `cd` that learns your habits |
| [eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) | modern `ls` / `cat` |
| [fd](https://github.com/sharkdp/fd) · [ripgrep](https://github.com/BurntSushi/ripgrep) | fast `find` / `grep` (fd powers fzf) |
| [delta](https://github.com/dandavison/delta) | syntax-highlighting pager for `git diff` |
| [tealdeer](https://github.com/tealdeer-rs/tealdeer) | `tldr` — quick, offline command examples |
| [lazygit](https://github.com/jesseduffield/lazygit) | terminal UI for git |
| [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) | editor, config vendored in [`nvim/`](nvim/) |
| [jq](https://github.com/jqlang/jq) · [yq](https://github.com/mikefarah/yq) | JSON / YAML processing |
| [direnv](https://direnv.net) · [carapace](https://carapace.sh) | per-directory env · unified completions |
| [tmux](https://github.com/tmux/tmux) | persistent SSH sessions ([`tmux/tmux.conf`](tmux/tmux.conf)) |

Everything degrades gracefully: aliases and hooks only activate when the tool is
present, so a `--minimal` box still works.

---

## The prompt

Starship, styled as rounded **Catppuccin Mocha** pills; empty segments vanish.

| Segment | Shows |
| ------- | ----- |
| ` user@host` | **only over SSH** (root in red) — which machine you're on |
| `󰕈  os` | the OS / distro |
| ` directory` | path, repo-root **bold**, `…/` truncation, folder icons |
| ` git` | branch + status (`!` modified · `?` untracked · `+` staged · `⇡/⇣` ahead/behind) |
| ` lang` | Node / Python / Rust / Go / Java / PHP / C versions, when in a project |
| ` docker · ☸ k8s ·  aws` | container / **cluster** / **cloud account** context, when set |
| right side | ` elapsed time` of the last command + ` HH:MM:SS` timestamp |

The `❯` turns **red** when the last command failed. Kube/AWS segments can be scoped
to infra directories — see the commented `detect_*` filters in `starship.toml`.

---

## Keyboard shortcuts

| Key | Does |
| --- | ---- |
| `Ctrl-R` | fuzzy-search shell history (fzf) |
| `Ctrl-T` | fuzzy-pick a file path into the command line |
| `Alt-C` | fuzzy `cd` into a subdirectory |
| `Tab` | fuzzy completion menu with previews (fzf-tab) |
| `→` / `End` | accept the greyed-out autosuggestion; `Ctrl-→` accepts one word |
| `↑` / `↓` | history search matching what you've already typed |
| `Ctrl-P` / `Ctrl-N` | same as `↑` / `↓` |
| `z <dir>` | jump to a frecent directory (zoxide) |
| `zi` | pick a directory to jump to, interactively |

---

## Aliases

Defined in [`zsh/aliases.zsh`](zsh/aliases.zsh). Tool-specific ones only exist when
the tool is installed.

**Files & search**

| Alias | Command |
| ----- | ------- |
| `ls` | `eza --group-directories-first --icons` |
| `ll` | long list + git status |
| `la` | list all (incl. dotfiles) |
| `lt` | tree, 2 levels deep |
| `cat` | `bat` (syntax highlighting) |
| `fd` | `fdfind` on Debian/Ubuntu |
| `rgi` | `rg -i` (case-insensitive ripgrep) |

**Navigation**

| Alias | Command |
| ----- | ------- |
| `..` `...` `....` | up 1 / 2 / 3 directories |
| `path` | print `$PATH`, one entry per line |

**Git** (plus `lg` → lazygit)

| Alias | Command | Alias | Command |
| ----- | ------- | ----- | ------- |
| `g` | `git` | `gd` | `git diff` |
| `gs` | `git status -sb` | `gco` | `git checkout` |
| `ga` | `git add` | `gb` | `git branch` |
| `gc` / `gca` | `git commit` / `-a` | `gl` | pretty log (last 20) |
| `gp` / `gpl` | `git push` / `pull` | `gla` | pretty log, all branches |

**DevOps / sysadmin** (only if the tool is present)

| Alias | Command | Alias | Command |
| ----- | ------- | ----- | ------- |
| `k` | `kubectl` | `d` | `docker` |
| `kg` / `kd` | `kubectl get` / `describe` | `dps` | `docker ps` |
| `klo` | `kubectl logs -f` | `dc` | `docker compose` |
| `kx` | switch cluster (context) | `tf` | `terraform` |
| `kns` | switch namespace | `ap` | `ansible-playbook` |
| `sc` / `scu` | `systemctl` / `--user` | `t` / `ta` / `tls` | tmux / attach / list |
| `jc` / `jcu` | `journalctl` / `--user` | | |

**Editor & handy**

| Alias | Command |
| ----- | ------- |
| `v` / `vi` / `vim` | `nvim` |
| `reload` | `exec zsh` (reload after config changes) |
| `zshrc` | edit `~/.zshrc` |
| `please` | re-run the last command with `sudo` |
| `myip` | your public IP |
| `ports` | listening ports (`ss` on Linux, `lsof` on macOS) |

---

## Plugins

Loaded via zinit **turbo mode** — asynchronously, right after the prompt appears,
so startup stays instant.

| Plugin | What you get |
| ------ | ------------ |
| **zsh-autosuggestions** | greys out the rest of a matching past command as you type; `→`/`End` accepts it |
| **fast-syntax-highlighting** | colors the command line live — valid commands green, unknown red — so you catch typos before Enter |
| **fzf-tab** | replaces the plain `Tab` menu with a fuzzy fzf selector + previews |
| **zsh-history-substring-search** | type a fragment, then `↑`/`↓` cycles only matching history |
| **zsh-completions** | a large bundle of extra `Tab`-completion definitions |
| **zsh-you-should-use** | reminds you when a command has an alias you defined |

---

## Editor & git UI

### lazygit (`lg`)
Full-screen git UI — stage, commit, branch, rebase, resolve conflicts; diffs
render through delta.

| Key | Does | Key | Does |
| --- | ---- | --- | ---- |
| `?` | keybinding help | `c` / `A` | commit / amend |
| `Tab` / `←` `→` | move panels | `p` / `P` / `f` | pull / push / fetch |
| `Space` | context action (stage, checkout, apply) | `n` / `d` / `M` / `r` | branch: new / del / merge / rebase |
| `Enter` | stage individual lines/hunks | `s` / `x` / `q` | stash / menu / quit |

### LazyVim (Neovim)
Leader is **`Space`** — press and pause for a which-key menu of everything. First
`nvim` launch installs plugins; run `:LazyHealth` to verify.

| Key | Does | Key | Does |
| --- | ---- | --- | ---- |
| `<Space>` | which-key popup | `<Space>gg` | open lazygit in Neovim |
| `<Space><Space>` | find files | `<S-h>` / `<S-l>` | prev / next buffer |
| `<Space>/` | live-grep project | `gd` · `gr` · `K` | definition · refs · hover |
| `<Space>e` | file explorer | `<Space>ca` · `<Space>cr` | code action · rename |
| `<Space>,` | switch buffers | `<Space>l` · `<Space>cm` | Lazy · Mason |

Ships with **Catppuccin Mocha** (matching the shell + tmux) and LazyVim language
extras for **Docker, Terraform, YAML, JSON, Markdown, Python** (LSP + formatters +
treesitter). Toggle more with `:LazyExtras`; extend via
[`nvim/lua/plugins/`](nvim/lua/plugins/).

---

## tmux

[`tmux/tmux.conf`](tmux/tmux.conf) — mouse on, vi copy mode, 1-based windows,
truecolor, and a Catppuccin status bar matching the prompt. Prefix stays `Ctrl-b`.

| Key | Does |
| --- | ---- |
| `prefix` `|` / `prefix` `-` | split vertical / horizontal (keeps cwd) |
| `prefix` `h` `j` `k` `l` | move between panes (vi-style) |
| `Alt` + arrows | switch panes **without** the prefix |
| `prefix` `H` `J` `K` `L` | resize the pane (repeatable) |
| `prefix` `[` then `v` / `y` | select / copy to the system clipboard (OSC52 — works over SSH) |
| `prefix` `c` | new window (keeps cwd) |
| `prefix` `r` | reload the config |

---

## Configuration & overrides

- **Per-machine settings** (secrets, local `PATH`, work aliases) go in
  `~/.zshrc.local` — sourced last, only if you own it, and **git-ignored**. Start
  from [`zsh/zshrc.local.example`](zsh/zshrc.local.example).
- **git-delta** is wired into `~/.gitconfig` via an `include` — additive and
  reversible; your existing git config is never rewritten.
- **AI assistants** working in this repo: see [`CLAUDE.md`](CLAUDE.md) for the
  symlink model, turbo load-order, and invariants.

---

## Security & production notes

Built to run on servers and privileged boxes — full details in
[`SECURITY.md`](SECURITY.md):

- **Know where you are** — `user@host` over SSH (root in red) + Kubernetes/AWS
  context in the prompt.
- **Secrets stay out of history** — commands typed with a leading space aren't
  saved (`HIST_IGNORE_SPACE`); never commit secrets (`~/.zshrc.local` is ignored).
- **`compinit -i`** keeps the security check and skips insecure completion dirs
  (never `-C`, which would bypass it).
- **Supply chain** — tools install from your package manager first; `curl | sh`
  is only a labelled fallback; lazygit/neovim binaries are **SHA256-verified**;
  `ZINIT_PIN` pins zinit for reproducible builds.
- **Air-gapped** — `./install.sh --offline` skips every fetch;
  [`scripts/vendor-plugins.sh`](scripts/vendor-plugins.sh) pre-seeds the plugins.
- **Auditable** — every run logs to `~/.local/state/console/install-<ts>.log`.
- **External SSH agents** (1Password / Vault) supported by pointing
  `SSH_AUTH_SOCK` at their socket from `~/.zshrc.local`.

---

## Updating

Because the configs are symlinks into this repo, updating is a pull:

```bash
cd ~/code/console && git pull && exec zsh   # add ./install.sh if a new tool was added
```

Update the tools/plugins themselves:

| What | Command |
| ---- | ------- |
| zsh plugins | `zinit self-update && zinit update --all` |
| LazyVim plugins | `nvim` → `:Lazy update` (then commit `nvim/lazy-lock.json`) |
| CLI tools | your package manager (`sudo apt upgrade`, `brew upgrade`, …) |
| tldr pages | `tldr --update` |

---

## Uninstall

```bash
./uninstall.sh                                 # remove the symlinks + git-delta include
mv ~/.zshrc.pre-console.<timestamp> ~/.zshrc   # optional: restore your previous zshrc
exec zsh
```
`uninstall.sh` only removes symlinks that point into this repo (real files are
left alone) and doesn't uninstall packages.

---

## Repo layout

```text
.
├── install.sh              # idempotent bootstrap (Linux + macOS)
├── uninstall.sh            # reverse the symlinks + git include
├── zsh/
│   ├── .zshrc              # main config      ->  ~/.zshrc
│   ├── aliases.zsh         # aliases (sourced by .zshrc)
│   └── zshrc.local.example # template for ~/.zshrc.local
├── starship/starship.toml  # prompt           ->  ~/.config/starship.toml
├── nvim/                   # LazyVim config    ->  ~/.config/nvim
├── lazygit/config.yml      # lazygit (delta)   ->  ~/.config/lazygit/config.yml
├── tmux/tmux.conf          # tmux config       ->  ~/.config/tmux/tmux.conf
├── git/delta.gitconfig     # git-delta, included into ~/.gitconfig
├── scripts/vendor-plugins.sh  # pre-seed plugins for offline hosts
├── .github/workflows/ci.yml   # shellcheck + lint + multi-distro smoke test
├── CLAUDE.md · SECURITY.md · ROADMAP.md
└── README.md
```

See [`ROADMAP.md`](ROADMAP.md) for what's done and what's next.
