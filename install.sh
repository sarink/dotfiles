#!/bin/sh
# install.sh — copy dotfiles from this repo into $HOME.
#
# The repo is the source of truth: edit files here, then run ./install.sh to
# copy them to ~. Identical files are skipped; changed files show a diff before
# you're asked to replace them.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dotfiles to install (relative to the repo root).
FILES=".zshrc .zprofile .zshenv .vimrc .tmux.conf"

# install_file <src> <dest>
install_file() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -f "$dest" ]; then
      if cmp -s "$dest" "$src"; then
        echo "unchanged $dest"
        return
      fi

      # Show the installed file first, then the proposed repo version.
      # diff returns 1 for differences, which is expected under set -e.
      diff -u "$dest" "$src" || [ "$?" -eq 1 ]
    fi

    printf 'overwrite %s? [y/N] ' "$dest"
    read -r answer < /dev/tty
    case "$answer" in
      [yY]*) rm -f "$dest" ;;  # rm first so an old symlink isn't written through
      *) echo "skipped $dest"; return ;;
    esac
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "copied  $dest"
}

for f in $FILES; do
  install_file "$DOTFILES_DIR/$f" "$HOME/$f"
done

# Agent config: claude/ and codex/ mirror ~/.claude/ and ~/.codex/.
for agent in claude codex; do
  cd "$DOTFILES_DIR/$agent"
  find . -type f ! -name .DS_Store | while IFS= read -r f; do
    install_file "$DOTFILES_DIR/$agent/${f#./}" "$HOME/.$agent/${f#./}"
  done
done
