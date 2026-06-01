# dotfiles

## Zsh

Clone the contents of this repo into: ~/dotfiles:
```
git clone https://github.com/sarink/dotfiles.git ~/dotfiles
```

Symlink the zsh startup files:
```
ln -s ~/dotfiles/.zprofile ~/.zprofile
ln -s ~/dotfiles/.zshrc ~/.zshrc
```

`.zprofile` (login shells) sets up Homebrew; `.zshrc` (interactive shells) loads
the shared fragments (`.base`, `.docker`, `.macos`), initializes native zsh
completion, activates [mise](https://mise.jdx.dev/) for Node/Ruby/Python, and
sets the prompt.

### Notes

- **Completion** is native zsh (`compinit`). The old vendored bash completion
  files (`git`, `tmux`, `brew`) were removed — zsh ships better ones. Homebrew's
  zsh completions are picked up via `$fpath`.
- **Version management** uses `mise` instead of `nvm`. To make it honor existing
  `.nvmrc` files (in addition to `.tool-versions` / `mise.toml`), run once:
  ```
  mise settings add idiomatic_version_file_enable_tools node
  ```
- The shared fragments (`.base`, `.docker`, `.macos`) are POSIX-ish and also work
  if sourced from bash; only the prompt and completion are zsh-specific.

## Vim
Create a symbolic link for the vimrc config
```
ln -s ~/dotfiles/.vimrc ~/.vimrc
```

Clone vundle
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Open vim, run `:VundleInstall` to install vim plugins (official [vundle docs](https://github.com/VundleVim/Vundle.vim)

## Tmux
Create a symbolic link for the tmux config
```
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

Clone tmux plugin manager into: ~/dotfiles/.tmux/plugins/tpm
```
git clone git@github.com:tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Open tmux, run `<prefix>I` (probably `ctrl-aI`) to install tmux plugins (official [tpm docs](https://github.com/tmux-plugins/tpm)

