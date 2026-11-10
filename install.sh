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

# merge_json_defaults <src> <dest>
# Fill keys missing from dest with values from src, recursing into objects.
# Keys dest already has (including arrays) are kept as-is, so the repo file
# acts as defaults and never clobbers local settings.
merge_json_defaults() {
  src="$1"
  dest="$2"

  if [ ! -f "$dest" ]; then
    install_file "$src" "$dest"
    return
  fi

  merged="$(mktemp)"
  jq --slurpfile d "$src" '
    def defaults($d):
      reduce ($d | keys_unsorted[]) as $k (.;
        if has($k) then
          if (.[$k] | type) == "object" and ($d[$k] | type) == "object"
          then .[$k] |= defaults($d[$k]) else . end
        else .[$k] = $d[$k] end);
    defaults($d[0])
  ' "$dest" > "$merged"

  # jq reformats; compare semantically so formatting alone isn't a change.
  if [ "$(jq -S . "$dest")" = "$(jq -S . "$merged")" ]; then
    echo "unchanged $dest"
  else
    install_file "$merged" "$dest"
  fi
  rm -f "$merged"
}

for f in $FILES; do
  install_file "$DOTFILES_DIR/$f" "$HOME/$f"
done

# Agent config: claude/ and codex/ mirror ~/.claude/ and ~/.codex/.
for agent in claude codex; do
  cd "$DOTFILES_DIR/$agent"
  find . -type f ! -name .DS_Store | while IFS= read -r f; do
    case "$agent/${f#./}" in
      claude/settings.json) merge_json_defaults "$DOTFILES_DIR/$agent/${f#./}" "$HOME/.$agent/${f#./}" ;;
      *) install_file "$DOTFILES_DIR/$agent/${f#./}" "$HOME/.$agent/${f#./}" ;;
    esac
  done
done
