#!/bin/sh
# install.sh — copy dotfiles from this repo into $HOME.
#
# The repo is the source of truth: edit files here, then run ./install.sh to
# push them to ~. Existing real files are backed up to <file>.bak; leftover
# symlinks from the old setup are replaced.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dotfiles to install (relative to the repo root).
FILES=".zshrc .zprofile .zshenv .vimrc .tmux.conf"

for f in $FILES; do
  src="$DOTFILES_DIR/$f"
  dest="$HOME/$f"

  if [ ! -f "$src" ]; then
    echo "skip   $f (not in repo)"
    continue
  fi

  if [ -L "$dest" ]; then
    # Old symlink from the previous setup — drop it.
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    # Real file already there — back it up before overwriting.
    cp "$dest" "$dest.bak"
    echo "backup $f -> $f.bak"
  fi

  cp "$src" "$dest"
  echo "copied $f -> $dest"
done
