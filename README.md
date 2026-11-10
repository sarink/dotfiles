# dotfiles

The repo is the source of truth. Edit files here, then run `./install.sh` to
copy them into `~`. (No symlinks — `install.sh` copies, skips identical files,
and shows a diff before asking to replace a changed file. Removed lines are
from the installed copy; added lines are from the repo.)

## Install

Clone the repo and run the install script:

```
git clone https://github.com/sarink/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This copies the shell, vim, and tmux dotfiles into `~`, the Claude Code
config into `~/.claude`, and the Codex config into `~/.codex`. It then clones
the vim and tmux plugin managers (Vundle and tpm) if they are missing and
installs the plugins declared in `.vimrc` and `.tmux.conf`, all without opening
vim or tmux. Files and plugins for `zsh`, `vim`, `tmux`, `claude`, or `codex`
are skipped when that command isn't on your `PATH`; install the tool and rerun
to pick them up. To update your home copies after editing anything in the repo,
just run `./install.sh` again.

## Zsh

`.zprofile` (login shells) sets up Homebrew; `.zshrc` (interactive shells)
loads the shared fragments, initializes native zsh completion, activates
[mise](https://mise.jdx.dev/) for Node/Ruby/Python, and sets the prompt.

### Machine-local config

Everything in this repo is meant to be portable across machines. Anything
specific to one Mac (extra `PATH` entries for locally installed tools, work
env vars, one-off aliases) goes in `~/.zshrc.local`, which `.zshrc` sources at
the very end if the file exists. It is not tracked here and not touched by
`install.sh` — create it by hand on each machine that needs it:

```
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc.local
```

`.zshrc.local` is not a zsh built-in, just a common convention; it only works
because of the `source` line at the bottom of `.zshrc`.

### Notes

- **Completion** is native zsh (`compinit`). The old vendored bash completion
  files (`git`, `tmux`, `brew`) were removed — zsh ships better ones. Homebrew's
  zsh completions are picked up via `$fpath`.
- **Version management** uses `mise` instead of `nvm`. To make it honor existing
  `.nvmrc` files (in addition to `.tool-versions` / `mise.toml`), run once:
  ```
  mise settings add idiomatic_version_file_enable_tools node
  ```
- The shared fragments are POSIX-ish and also work if sourced from bash; only
  the prompt and completion are zsh-specific.

## Vim

`install.sh` copies `.vimrc`, clones [vundle](https://github.com/VundleVim/Vundle.vim)
into `~/.vim/bundle/Vundle.vim` if it isn't there, and runs `:PluginInstall`
headlessly. Add plugins as `Plugin '...'` lines in `.vimrc` and re-run
`./install.sh` (or `:PluginInstall` inside vim).

## Tmux

`install.sh` copies `.tmux.conf`, clones [tpm](https://github.com/tmux-plugins/tpm)
into `~/.tmux/plugins/tpm` if it isn't there, and installs the declared plugins
with tpm's `install_plugins` script. Add plugins as `set -g @plugin '...'` lines
in `.tmux.conf` and re-run `./install.sh` (or `<prefix>I` inside tmux).

Plugins in use:

- **tmux-resurrect** — `<prefix>ctrl-s` saves sessions, `<prefix>ctrl-r` restores.
- **tmux-continuum** — auto-saves every 15 minutes and restores on tmux start
  (`@continuum-restore on`).

If tmux is already running when you run `./install.sh`, reload the config with
`tmux source ~/.tmux.conf` so the new plugins take effect.

## Claude Code

`claude/` mirrors `~/.claude/` — `install.sh` copies every file in it:

- `settings.json` — Claude Code settings
- `statusline.sh` — status line script
- `skills/` — personal skills (`/eli5`, `/handoff` (MIT, from mattpocock/skills), `/id`, `/qq`, `/screenshot`, and `/ponytail` with its `-review`, `-audit`, `-debt`, `-help`: MIT, from DietrichGebert/ponytail, changed to run only when invoked and only for that request)

Claude Code separates settings from instructions: `~/.claude/settings.json`
controls settings and hooks, while `~/.claude/CLAUDE.md` holds user-level
instructions for all projects. To carry standing instructions across machines,
add `claude/CLAUDE.md` here; the installer will copy it automatically.
Project settings live in `.claude/settings.json`; personal project overrides
live in `.claude/settings.local.json`.

The installer targets `~/.claude`, or `$CLAUDE_CONFIG_DIR` when set. To
install into a second config dir (e.g. the `claudef` alias's `~/.claudef`):

```
CLAUDE_CONFIG_DIR=~/.claudef ./install.sh
```

Paths in `settings.json` use `~/.claude/...`, never an absolute home dir, so
they work on any machine.

`settings.json` is merged, not copied: `install.sh` (using `jq`) adds only
the keys missing from `~/.claude/settings.json`, recursing into objects. A key
the installed file already sets, including any array such as a hook list or
`permissions.allow`, is left alone. So the repo values are defaults, and local
changes (from `/config`, `/model`, plugins, etc.) are kept. Since nothing
local is lost, the merge is written without asking; the diff of added keys is
printed. To change a value
that is already set locally, edit `~/.claude/settings.json` directly or delete
the key and run `install.sh` again.

## Codex

`codex/` mirrors `~/.codex/` — `install.sh` copies every file in it:

- `config.toml` — portable settings: full access, no approval prompts, and no alternate screen.
- `skills/` — Codex versions of all ten Claude skills: `$eli5`, `$handoff`,
  `$id`, `$qq`, `$screenshot`, `$ponytail`, `$ponytail-review`,
  `$ponytail-audit`, `$ponytail-debt`, and `$ponytail-help`. The first five require explicit
  invocation; `$qq` stays read-only until explicitly released. Ponytail
  applies only to the request where it is invoked.

Edit the files in `codex/` here and run `./install.sh` on each machine after
pulling the repo. Start a new Codex session to load updated settings and skills.
The installer targets `~/.codex`, or `$CODEX_HOME` when set.

`config.toml` sets `approval_policy = "never"`,
`sandbox_mode = "danger-full-access"`, and `tui.alternate_screen = "never"`.

`config.toml` is merged the same way as Claude's `settings.json`: `install.sh`
adds only the keys missing from `~/.codex/config.toml` (under the existing
`[table]` header, or in a new one at the end) and leaves everything else,
comments and formatting included, as it is. Values you set locally, plus the
project trust entries and model choices Codex writes there, are kept. The merge
needs `python3` 3.11+ (`tomllib`); with an older Python the installer falls back
to asking whether to replace the whole file. Keep credentials, session history,
and machine-specific project trust entries out of this repo.
