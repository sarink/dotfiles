#!/bin/sh
# install.sh — copy dotfiles from this repo into $HOME.
#
# The repo is the source of truth: edit files here, then run ./install.sh to
# copy them to ~. If a file already exists, you're asked before it's replaced.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dotfiles to install (relative to the repo root).
FILES=".zshrc .zprofile .zshenv .vimrc .tmux.conf"

# install_file <src> <dest>
install_file() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
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

# Claude Code config: everything under claude/ mirrors ~/.claude/.
cd "$DOTFILES_DIR/claude"
find . -type f ! -name .DS_Store | while read -r f; do
  install_file "$DOTFILES_DIR/claude/${f#./}" "$HOME/.claude/${f#./}"
done
