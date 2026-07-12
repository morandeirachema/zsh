<div align="center">

# ⌨️ &nbsp;console

### A fast, portable, production-grade **zsh** setup — one clone, every machine.

[![CI](https://github.com/morandeirachema/zsh/actions/workflows/ci.yml/badge.svg)](https://github.com/morandeirachema/zsh/actions/workflows/ci.yml)
![shell](https://img.shields.io/badge/shell-zsh-1e88e5)
![platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-4c566a)
![prompt](https://img.shields.io/badge/prompt-starship-DD0B78)
![theme](https://img.shields.io/badge/theme-Catppuccin%20Mocha-cba6f7)

```console
 󰕈    ~/code/console    main   !2 ?1                              2.4s   14:32:07
❯ ▏
```

*Over SSH the prompt grows a `user@host` badge (root in red) and your Kubernetes / AWS context —*
*so you never run a command on the wrong box:*

```console
root@web-01  󰕈    /etc/nginx    main   ☸ prod:web    aws prod-admin          14:32
❯ ▏
```

**[Quick start](#-quick-start)** · **[What's inside](#-whats-inside)** · **[Shortcuts](#️-keyboard-shortcuts)** · **[Aliases](#-aliases)** · **[Security](#-security--production)**

</div>

---

It started as a personal desktop shell and grew into something you can trust on a
fleet of servers: **instant startup**, **the same everywhere**, **safe on
privileged boxes**, and **reversible**. One `git clone` + one command and every
Linux or macOS machine looks and behaves identically.

## ✨ Highlights

- ⚡ **Instant startup** — plugins load *asynchronously* after the prompt (zinit turbo mode).
- 🧭 **Never act on the wrong target** — `user@host` over SSH (root in red) + live Kubernetes / AWS context in the prompt.
- 📦 **One command, any distro** — idempotent installer for apt · dnf · pacman · zypper · **Homebrew**.
- 🔒 **Hardened by default** — secure `compinit`, secrets kept out of history, **SHA256-verified** downloads, non-destructive git config.
- 🧊 **Reproducible & air-gappable** — pinned plugins, `--offline` mode, plugin vendoring.
- ↩️ **Reversible** — timestamped backups, `uninstall.sh`, and an install audit log.
- 🪶 **Degrades gracefully** — every tool/alias is guarded, so a `--minimal` box still works.

---

## 🚀 Quick start

> [!NOTE]
> Only `git` + `curl` are needed up front — the installer adds everything else.

```bash
git clone https://github.com/morandeirachema/zsh.git ~/code/console
cd ~/code/console
./install.sh
exec zsh
```

The installer is **idempotent** (safe to re-run). It detects your package manager,
installs missing tools, backs up any existing `~/.zshrc` → `~/.zshrc.pre-console.<ts>`,
then symlinks this repo into place. The first launch of `zsh` (and of `nvim`)
installs plugins once.

> [!TIP]
> Preview a run without changing anything — `./install.sh --dry-run`.
> Audit an existing setup (tools · symlinks · font · git) — `./install.sh --doctor`.

<details>
<summary><b>🍎 macOS notes &nbsp;·&nbsp; 🚩 all install flags</b></summary>

<br>

**macOS:** install [Homebrew](https://brew.sh) and — for Neovim's treesitter — the
Xcode CLT (`xcode-select --install`). The login shell is already zsh, so it isn't
changed; the Nerd Font is installed via `brew --cask`.

| Flag | Effect |
| ---- | ------ |
| `--dry-run` | print every package/symlink/change the run **would** make — touch nothing |
| `--doctor` | health check: report tools, symlinks, font, git config — then exit |
| `--minimal` | zsh + plugins + prompt only (skip the extra CLI tools, nvim, font) |
| `--server` | headless box: skip the Nerd Font (it lives on your client) |
| `--offline` | air-gapped: no internet fetches — packages come from your mirror |
| `--xdg` | put `.zshrc` under `ZDOTDIR=~/.config/zsh` to keep `$HOME` tidy |
| `--no-nvim` | don't install Neovim/LazyVim or touch `~/.config/nvim` |
| `--no-fabric` | don't install [fabric](https://github.com/danielmiessler/fabric) (the AI-patterns CLI) |
| `--no-alacritty` | don't install [Alacritty](https://alacritty.org) or link its config |
| `--no-font` | skip the Nerd Font download |
| `--no-chsh` | don't change the default login shell |
| `-y`, `--yes` | non-interactive |

</details>

> [!TIP]
> Using the bundled **Alacritty** config? The font is already set — nothing to do.
> On any other terminal, set its font to **JetBrainsMono Nerd Font** so the prompt
> icons render (e.g. kitty: `font_family JetBrainsMono Nerd Font`).

---

## 🧩 What's inside

| | Tool | Role |
|---|------|------|
| 🔌 | [zinit](https://github.com/zdharma-continuum/zinit) | plugin manager — **turbo mode** loads plugins async for instant startup |
| 🚀 | [starship](https://starship.rs) | the prompt ([`starship/starship.toml`](starship/starship.toml)) |
| 🔍 | [fzf](https://github.com/junegunn/fzf) | fuzzy finder — history, files, cd |
| 📁 | [zoxide](https://github.com/ajeetdsouza/zoxide) | smarter `cd` that learns your habits |
| 📃 | [eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) | modern `ls` / `cat` |
| ⚡ | [fd](https://github.com/sharkdp/fd) · [ripgrep](https://github.com/BurntSushi/ripgrep) | fast `find` / `grep` (fd powers fzf) |
| 🌈 | [delta](https://github.com/dandavison/delta) | syntax-highlighting pager for `git diff` |
| 📖 | [tealdeer](https://github.com/tealdeer-rs/tealdeer) | `tldr` — quick, offline command examples |
| 🐙 | [lazygit](https://github.com/jesseduffield/lazygit) | full-screen terminal UI for git |
| ✏️ | [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) | editor, config vendored in [`nvim/`](nvim/) |
| 🧮 | [jq](https://github.com/jqlang/jq) · [yq](https://github.com/mikefarah/yq) | JSON / YAML processing |
| 🌱 | [direnv](https://direnv.net) · [carapace](https://carapace.sh) | per-directory env · completions for 1000+ tools |
| 🪟 | [tmux](https://github.com/tmux/tmux) | persistent SSH sessions, survive reboots — plus a [sessionizer](#-tmux) (`prefix f`) |
| 🔑 | [pass](https://www.passwordstore.org) | GPG-encrypted password store (bring your own key) |
| 🤖 | [fabric](https://github.com/danielmiessler/fabric) | run AI "patterns" as Unix filters (`--no-fabric` to skip) |
| 🖥️ | [Alacritty](https://alacritty.org) | GPU terminal, Catppuccin + Nerd Font preset ([`alacritty/`](alacritty/); `--no-alacritty` to skip) |

---

## 🎨 The prompt

Starship, styled as rounded **Catppuccin Mocha** pills — empty segments vanish, so
it stays clean and only shows what's relevant.

| Segment | Shows | When |
| ------- | ----- | ---- |
| ` user@host` | which machine you're on (root in **red**) | over SSH |
| `󰕈 os` | the OS / distro | always |
| ` directory` | path — repo-root **bold**, `…/` truncation, folder icons | always |
| ` git` | branch + status | in a repo |
| ` lang` | Node · Python · Rust · Go · Java · PHP · C versions | in a project |
| `☸ k8s ·  aws · docker` | **cluster** · **cloud account** · container context | when set |
| *(right)* | ` elapsed time` of the last command + ` HH:MM:SS` | always |

Git status glyphs: `!` modified · `?` untracked · `+` staged · `»` renamed · `✘` deleted · `⇡`/`⇣` ahead/behind. The `❯` turns **red** when the last command failed.

> [!TIP]
> The kube/AWS segments can be scoped to infra directories — see the commented
> `detect_*` filters in [`starship.toml`](starship/starship.toml).

---

## ⌨️ Keyboard shortcuts

| Key | Does |
| --- | ---- |
| `Ctrl-R` | fuzzy-search shell history (fzf) |
| `Ctrl-T` | fuzzy-pick a file path — **previews** with bat / eza-tree |
| `Alt-C` | fuzzy `cd` into a subdirectory — **previews** the tree |
| `Ctrl-/` | toggle the preview pane on/off (in any fzf widget) |
| `Tab` | fuzzy completion menu with previews (fzf-tab) |
| `→` / `End` | accept the greyed-out autosuggestion (`Ctrl-→` = one word) |
| `↑` / `↓` &nbsp;·&nbsp; `Ctrl-P` / `Ctrl-N` | history search matching what you've typed |
| `z <dir>` &nbsp;·&nbsp; `zi` | jump to a frecent directory · pick interactively |

---

## 🔤 Aliases

The everyday ones — full reference is collapsed below. Tool-specific aliases only
exist when the tool is installed.

| Alias | Does | Alias | Does |
| ----- | ---- | ----- | ---- |
| `ll` / `la` / `lt` | eza list / all / tree | `gs` | `git status -sb` |
| `cat` | `bat` (highlighted) | `gl` | pretty git log |
| `lg` | lazygit | `gd` | `git diff` (delta) |
| `v` / `vi` / `vim` | `nvim` | `reload` | `exec zsh` |
| `..` / `...` | up 1 / 2 dirs | `please` | re-run last cmd with `sudo` |

<details>
<summary><b>Full alias reference</b> — files, git, DevOps/sysadmin, handy</summary>

<br>

**Files & search**

| Alias | Command |
| ----- | ------- |
| `ls` `ll` `la` `lt` | eza: list · long+git · all · tree (2 levels) |
| `cat` | `bat --paging=never` |
| `fd` | `fdfind` on Debian/Ubuntu (also drives fzf) |
| `rgi` | `rg -i` |

**Git** (`lg` → lazygit)

| Alias | Command | Alias | Command |
| ----- | ------- | ----- | ------- |
| `g` | `git` | `gd` | `git diff` |
| `gs` | `git status -sb` | `gco` `gb` | checkout · branch |
| `ga` | `git add` | `gl` | pretty log (last 20) |
| `gc` `gca` | commit · commit -a | `gla` | pretty log, all branches |
| `gp` `gpl` | push · pull | | |

**DevOps / sysadmin** *(only if the tool is present)*

| Alias | Command | Alias | Command |
| ----- | ------- | ----- | ------- |
| `k` | `kubectl` | `d` `dps` `dc` | docker · ps · compose |
| `kg` `kd` | get · describe | `tf` | terraform |
| `klo` | `logs -f` | `ap` | ansible-playbook |
| `kx` | switch cluster | `t` `ta` `tls` | tmux · attach · list |
| `kns` | switch namespace | `sc` `scu` | systemctl · --user |
| | | `jc` `jcu` | journalctl · --user |

**AI & secrets** *(only if the tool is present)*

| Alias | Command |
| ----- | ------- |
| `pw` `pwc` | `pass` · `pass -c` (copy a secret to the clipboard) |
| `passf` | fuzzy-pick a `pass` entry and copy it (needs fzf) |
| `fab` | `fabric` — run an AI pattern |
| `fsum` `fexplain` | `fabric --pattern summarize` · `explain_code` (pipe into them) |
| `ytsum <url>` | summarize a YouTube video's transcript |

**Navigation & handy**

| Alias | Command |
| ----- | ------- |
| `..` `...` `....` | up 1 / 2 / 3 dirs |
| `path` | print `$PATH`, one entry per line |
| `reload` | `exec zsh` |
| `zshrc` | edit `~/.zshrc` |
| `please` | re-run the last command with `sudo` |
| `myip` | your public IP |
| `ports` | listening ports (`ss` Linux / `lsof` macOS) |

</details>

---

## 🔌 Plugins

Loaded via zinit **turbo mode** — asynchronously, right after the prompt, so
startup stays instant.

| Plugin | What you get |
| ------ | ------------ |
| **zsh-autosuggestions** | greys out the rest of a matching past command; `→`/`End` accepts it |
| **fast-syntax-highlighting** | live coloring — valid commands green, unknown red — catch typos before Enter |
| **fzf-tab** | replaces the plain `Tab` menu with a fuzzy fzf selector + previews |
| **zsh-history-substring-search** | type a fragment, `↑`/`↓` cycles only matching history |
| **zsh-completions** | a large bundle of extra `Tab`-completion definitions |
| **zsh-you-should-use** | reminds you when a command has an alias you defined |

Plus [**carapace**](https://carapace.sh) for value-aware completions across 1000+
tools — `kubectl get pods -n <Tab>` completes your real namespaces, `git checkout
<Tab>` your branches, `aws --profile <Tab>` your profiles.

---

## ✏️ Editor & git UI

<details open>
<summary><b>lazygit</b> (<code>lg</code>) — stage, commit, branch, rebase without memorizing flags</summary>

<br>

| Key | Does | Key | Does |
| --- | ---- | --- | ---- |
| `?` | keybinding help | `c` / `A` | commit / amend |
| `Tab` `←` `→` | move panels | `p` / `P` / `f` | pull / push / fetch |
| `Space` | context action (stage, checkout, apply) | `n` `d` `M` `r` | branch: new · del · merge · rebase |
| `Enter` | stage individual lines/hunks | `s` / `x` / `q` | stash / menu / quit |

</details>

<details>
<summary><b>LazyVim</b> (Neovim) — leader is <code>Space</code>; press and pause for a which-key menu</summary>

<br>

| Key | Does | Key | Does |
| --- | ---- | --- | ---- |
| `<Space>` | which-key popup | `<Space>gg` | open lazygit in Neovim |
| `<Space><Space>` | find files | `<S-h>` / `<S-l>` | prev / next buffer |
| `<Space>/` | live-grep project | `gd` · `gr` · `K` | definition · refs · hover |
| `<Space>e` | file explorer | `<Space>ca` · `<Space>cr` | code action · rename |
| `<Space>,` | switch buffers | `<Space>l` · `<Space>cm` | Lazy · Mason |

Ships with **Catppuccin Mocha** (matching the shell + tmux) and language extras
for **Docker · Terraform · YAML · JSON · Markdown · Python** (LSP + formatters +
treesitter). Plugin versions are pinned in `nvim/lazy-lock.json`. Toggle more with
`:LazyExtras`; extend via [`nvim/lua/plugins/`](nvim/lua/plugins/).

</details>

---

## 🪟 tmux

[`tmux/tmux.conf`](tmux/tmux.conf) — mouse, vi copy mode, truecolor, and a
Catppuccin status bar matching the prompt (prefix stays `Ctrl-b`).

| Key | Does |
| --- | ---- |
| `prefix` `f` | **sessionizer** — fzf-pick a project dir → open/switch to its session |
| `prefix` `|` / `-` | split vertical / horizontal (keeps cwd) |
| `prefix` `h` `j` `k` `l` | move between panes |
| `Alt` + arrows | switch panes **without** the prefix |
| `prefix` `H` `J` `K` `L` | resize the pane (repeatable) |
| `prefix` `[` → `v` / `y` | select / copy to system clipboard (OSC52 — works over SSH) |
| `prefix` `Ctrl-s` / `Ctrl-r` | save / restore the session |

> [!TIP]
> **`prefix f` (tmux-sessionizer)** gives you one session per project. It searches
> `~/code ~/projects ~/src ~/work ~/dev` by default — override with
> `export TMUX_SESSIONIZER_PATHS="$HOME/code $HOME/work"` in `~/.zshrc.local`. The
> script ([`scripts/tmux-sessionizer.sh`](scripts/tmux-sessionizer.sh)) is on your
> `PATH` too, so `tmux-sessionizer` works from any shell.

> [!IMPORTANT]
> Sessions **persist across reboots** via
> [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) +
> [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) (auto-save every
> 15 min, auto-restore on start). Pane *contents* are deliberately **not** saved,
> so scrollback secrets never hit disk.

---

## 🖥️ Terminal (Alacritty)

[`alacritty/alacritty.toml`](alacritty/alacritty.toml) — a GPU-accelerated terminal
preset in **Catppuccin Mocha** with **JetBrainsMono Nerd Font** baked in, so the
whole stack (terminal → prompt → tmux → nvim) is one theme and glyphs render with
no manual font step. It's intentionally minimal — **tmux** provides tabs, splits,
and sessions.

Installed and linked by default on desktops; skipped on servers (`--server`) and
with `--no-alacritty`. Prefer a different terminal? Keep using it — just point its
font at *JetBrainsMono Nerd Font* and, optionally, drop in the Catppuccin Mocha
palette from the toml. Nothing else in the repo depends on Alacritty.

---

## ⚙️ Configuration

- **Per-machine settings** (secrets, local `PATH`, work aliases) → `~/.zshrc.local`,
  sourced last, only if you own it, and git-ignored. Start from
  [`zsh/zshrc.local.example`](zsh/zshrc.local.example).
- **git-delta** is wired into `~/.gitconfig` via an `include` — additive and
  reversible; your existing git config is never rewritten.
- **Passwords (`pass`)** — bring your own GPG key (`gpg --gen-key`), then
  `pass init <key-id>`. `GPG_TTY` is already exported so it can prompt in your
  terminal. `pw`/`pwc` copy secrets; `passf` fuzzy-picks one. It complements — not
  replaces — the 1Password/Vault SSH-agent setup in [`SECURITY.md`](SECURITY.md).
- **AI CLI (`fabric`)** — run `fabric --setup` once (stores config under
  `~/.config/fabric`). Put provider API keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`,
  …) in `~/.zshrc.local`, **never** in the repo. Then pipe into patterns:
  `cat notes.md | fsum`, `git diff | fexplain`, `ytsum <youtube-url>`.
- **AI assistants** working here: see [`CLAUDE.md`](CLAUDE.md).

---

## 🔒 Security & production

Built to run on servers and privileged boxes — full details in
[`SECURITY.md`](SECURITY.md).

<details>
<summary><b>The security model in one screen</b></summary>

<br>

| Concern | How it's handled |
| ------- | ---------------- |
| **Wrong box / cluster** | prompt shows `user@host` (SSH, root in red) + kube/AWS context |
| **Secrets in history** | leading-space commands aren't saved (`HIST_IGNORE_SPACE`) |
| **Secrets in the repo** | machine config lives in git-ignored `~/.zshrc.local` |
| **Completion injection** | `compinit -i` keeps the security check, skips insecure dirs (never `-C`) |
| **Supply chain** | packages first; `curl \| sh` only a labelled fallback; lazygit/neovim/carapace binaries **SHA256-verified** |
| **Reproducibility** | `nvim/lazy-lock.json`, `ZINIT_PIN`, `--offline`, `scripts/vendor-plugins.sh` |
| **Auditability** | every run logs to `~/.local/state/console/install-<ts>.log` |
| **Reversibility** | `~/.zshrc.pre-console.<ts>` backups + `./uninstall.sh` |
| **External key agents** | point `SSH_AUTH_SOCK` at 1Password / Vault from `~/.zshrc.local` |
| **AI / password secrets** | `pass` uses **your** GPG key; `fabric` API keys live in `~/.zshrc.local`, never the repo |

</details>

> [!CAUTION]
> On air-gapped hosts, `./install.sh --offline` skips every fetch — pre-seed the
> plugins with [`scripts/vendor-plugins.sh`](scripts/vendor-plugins.sh) first.

---

## 🔄 Updating

Because the configs are symlinks into this repo, updating is a pull:

```bash
cd ~/code/console && git pull && exec zsh   # add ./install.sh if a new tool was added
```

| Update | Command |
| ------ | ------- |
| zsh plugins | `zinit self-update && zinit update --all` |
| LazyVim plugins | `nvim` → `:Lazy update` (commit `nvim/lazy-lock.json`) |
| CLI tools | your package manager (`apt upgrade`, `brew upgrade`, …) |
| tldr pages | `tldr --update` |

---

## 🗑️ Uninstall

```bash
./uninstall.sh                                 # remove the symlinks + git-delta include
mv ~/.zshrc.pre-console.<timestamp> ~/.zshrc   # optional: restore your previous zshrc
exec zsh
```
It only removes symlinks that point into this repo (real files are left alone) and
doesn't uninstall packages.

---

## 🗂️ Repo layout

```text
.
├── install.sh              # idempotent bootstrap (Linux + macOS)
├── uninstall.sh            # reverse the symlinks + git include
├── zsh/
│   ├── .zshrc              # main config          ->  ~/.zshrc
│   ├── aliases.zsh         # aliases (sourced by .zshrc)
│   └── zshrc.local.example # template for ~/.zshrc.local
├── starship/starship.toml  # prompt               ->  ~/.config/starship.toml
├── nvim/                   # LazyVim config        ->  ~/.config/nvim
├── lazygit/config.yml      # lazygit (delta)       ->  ~/.config/lazygit/config.yml
├── tmux/tmux.conf          # tmux config           ->  ~/.config/tmux/tmux.conf
├── alacritty/alacritty.toml # terminal preset      ->  ~/.config/alacritty/alacritty.toml
├── git/delta.gitconfig     # git-delta, included into ~/.gitconfig
├── scripts/
│   ├── tmux-sessionizer.sh # fzf project switcher  ->  ~/.local/bin/tmux-sessionizer
│   ├── ci-extras-check.sh  # CI: assert pass/fabric/sessionizer/alacritty installed
│   ├── ci-uninstall-check.sh # CI: assert uninstall.sh removes every symlink
│   └── vendor-plugins.sh   # pre-seed plugins for offline hosts
├── .github/workflows/ci.yml    # shellcheck + lint + minimal/extras/uninstall multi-distro smoke
├── CLAUDE.md · SECURITY.md · ROADMAP.md
└── README.md
```

---

<div align="center">

Built to be cloned. See [`ROADMAP.md`](ROADMAP.md) for what's done and what's next.

</div>
