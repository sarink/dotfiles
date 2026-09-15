# dotfiles

The repo is the source of truth. Edit files here, then run `./install.sh` to
copy them into `~`. (No symlinks — `install.sh` copies, and asks before
replacing a file that already exists.)

## Install

Clone the repo and run the install script:

```
git clone https://github.com/sarink/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This copies the shell, vim, and tmux dotfiles into `~`, and the Claude Code
config into `~/.claude`. To update your home copies after editing anything in
the repo, just run `./install.sh` again.

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

`install.sh` copies `.vimrc`. Then clone vundle:

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Open vim, run `:VundleInstall` to install vim plugins (official [vundle docs](https://github.com/VundleVim/Vundle.vim)).

## Tmux

`install.sh` copies `.tmux.conf`. Then clone the tmux plugin manager:

```
git clone git@github.com:tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Open tmux, run `<prefix>I` (probably `ctrl-aI`) to install tmux plugins (official [tpm docs](https://github.com/tmux-plugins/tpm)).

## Claude Code

`claude/` mirrors `~/.claude/` — `install.sh` copies every file in it:

- `settings.json` — Claude Code settings
- `statusline.sh` — status line script
- `skills/` — personal skills (`/eli5`, `/qq`)

Paths in `settings.json` use `~/.claude/...`, never an absolute home dir, so
they work on any machine.

Claude Code also writes to `~/.claude/settings.json` itself (most `/config`
options, the `/model` default). Copy anything you want to keep back into the
repo before running `install.sh` — answering `y` replaces the file:

```
diff ~/.claude/settings.json claude/settings.json
cp ~/.claude/settings.json claude/settings.json
```
