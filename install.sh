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

# Plugin managers, cloned into $HOME if absent. Their plugins are then
# installed headlessly from whatever .vimrc / .tmux.conf declare.
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
TPM_DIR="$HOME/.tmux/plugins/tpm"

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

# merge_toml_defaults <src> <dest>
# Same as merge_json_defaults, for TOML. Missing keys are inserted as text
# (under their existing [table] header, or in a new one at the end) so the
# rest of dest, comments and formatting included, is left untouched.
merge_toml_defaults() {
  src="$1"
  dest="$2"

  if [ ! -f "$dest" ]; then
    install_file "$src" "$dest"
    return
  fi

  # macOS's /usr/bin/python3 is too old for tomllib; prefer one that has it.
  py=""
  for p in python3 /opt/homebrew/bin/python3 /usr/local/bin/python3; do
    if "$p" -c 'import tomllib' 2>/dev/null; then py="$p"; break; fi
  done
  if [ -z "$py" ]; then
    echo "warning: merging $dest needs python3 >= 3.11 (tomllib); falling back to replace"
    install_file "$src" "$dest"
    return
  fi

  merged="$(mktemp)"
  "$py" - "$src" "$dest" > "$merged" <<'EOF'
import json, re, sys, tomllib

src_path, dest_path = sys.argv[1], sys.argv[2]
with open(src_path, "rb") as f:
    src = tomllib.load(f)
with open(dest_path, "rb") as f:
    dest = tomllib.load(f)
with open(dest_path) as f:
    lines = f.read().splitlines()

def val(v):
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, str): return json.dumps(v, ensure_ascii=False)
    if isinstance(v, list): return "[" + ", ".join(val(x) for x in v) + "]"
    if isinstance(v, dict): return "{ " + ", ".join(f"{key(k)} = {val(x)}" for k, x in v.items()) + " }"
    raise SystemExit(f"unsupported TOML value: {v!r}")

def key(k):
    return k if re.fullmatch(r"[A-Za-z0-9_-]+", k) else json.dumps(k, ensure_ascii=False)

# Collect missing leaf keys, grouped by the table they belong in.
missing = {}
def walk(s, d, path):
    for k, v in s.items():
        if k in d:
            if isinstance(v, dict) and isinstance(d[k], dict):
                walk(v, d[k], path + (k,))
        elif isinstance(v, dict) and v:
            walk(v, {}, path + (k,))
        else:
            missing.setdefault(path, []).append(f"{key(k)} = {val(v)}")
walk(src, dest, ())

# Map each [table] header line in dest to its key path.
headers = {}
for i, line in enumerate(lines):
    if re.match(r"\s*\[[^\[]", line):
        try:
            t = tomllib.loads(line)
        except tomllib.TOMLDecodeError:
            continue
        path = ()
        while isinstance(t, dict) and len(t) == 1:
            (k, t), = t.items()
            path += (k,)
        headers.setdefault(path, i)

inserts, appends = {}, []
for path, kv in missing.items():
    if path == ():
        # Top-level keys must come before the first table header.
        at = min(headers.values(), default=len(lines))
        while at > 0 and not lines[at - 1].strip():
            at -= 1
        inserts.setdefault(at, []).extend(kv)
    elif path in headers:
        inserts.setdefault(headers[path] + 1, []).extend(kv)
    else:
        appends += ["", "[" + ".".join(key(k) for k in path) + "]", *kv]

out = []
for i, line in enumerate(lines + [None]):
    out += inserts.get(i, [])
    if line is not None:
        out.append(line)
out += appends
text = "\n".join(out) + "\n"

# Sanity check: result parses and every src key is now present.
result = tomllib.loads(text)
def check(s, d):
    for k, v in s.items():
        assert k in d, k
        if isinstance(v, dict) and isinstance(d[k], dict):
            check(v, d[k])
check(src, result)
sys.stdout.write(text if missing else open(dest_path).read())
EOF

  if cmp -s "$dest" "$merged"; then
    echo "unchanged $dest"
  else
    install_file "$merged" "$dest"
  fi
  rm -f "$merged"
}

# clone_if_missing <repo-url> <dest-dir>
clone_if_missing() {
  if [ -d "$2" ]; then
    echo "exists  $2"
  else
    git clone --quiet --depth 1 "$1" "$2"
    echo "cloned  $2"
  fi
}

for f in $FILES; do
  install_file "$DOTFILES_DIR/$f" "$HOME/$f"
done

# Agent config: claude/ and codex/ mirror ~/.claude/ and ~/.codex/, or
# $CLAUDE_CONFIG_DIR / $CODEX_HOME when set (e.g. CLAUDE_CONFIG_DIR=~/.claudef).
for agent in claude codex; do
  case "$agent" in
    claude) target="${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ;;
    codex) target="${CODEX_HOME:-$HOME/.codex}" ;;
  esac
  cd "$DOTFILES_DIR/$agent"
  find . -type f ! -name .DS_Store | while IFS= read -r f; do
    f="${f#./}"
    case "$agent/$f" in
      claude/settings.json) merge_json_defaults "$DOTFILES_DIR/$agent/$f" "$target/$f" ;;
      codex/config.toml) merge_toml_defaults "$DOTFILES_DIR/$agent/$f" "$target/$f" ;;
      *) install_file "$DOTFILES_DIR/$agent/$f" "$target/$f" ;;
    esac
  done
done

# Vim plugins via Vundle. -E -s runs vim non-interactively; -i NONE skips
# viminfo so nothing is written to $HOME besides the plugins themselves. Vim
# exits 1 if anything in .vimrc errored while the plugins were still missing,
# even when the install itself succeeded, so check for the plugin directories
# instead of trusting the exit code.
if command -v vim >/dev/null 2>&1; then
  clone_if_missing https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
  vim -E -s -u "$HOME/.vimrc" -i NONE -c 'PluginInstall' -c 'qall' </dev/null >/dev/null || true
  missing=$(sed -n "s|^Plugin '[^/']*/\([^']*\)'.*|\1|p" "$HOME/.vimrc" |
    while read -r name; do
      [ -d "$(dirname "$VUNDLE_DIR")/$name" ] || echo "$name"
    done)
  if [ -n "$missing" ]; then
    echo "vim plugin install failed, missing:" $missing >&2
    exit 1
  fi
  echo "installed vim plugins"
else
  echo "skipped vim plugins (vim not installed)"
fi

# Tmux plugins via tpm. Its install script asks a tmux server for the plugin
# path that tpm sets when .tmux.conf is sourced, so run it against a private
# throwaway server: TMUX_TMPDIR picks the socket dir and TMUX is unset so this
# works from inside an existing tmux session without touching that server.
# The clones are plain public GitHub repos; tpm uses `https://git::@github.com`
# URLs, which make git consult the credential helper, and on macOS the keychain
# helper can block waiting for user input. Clear it and disable prompts so the
# install stays non-interactive.
if command -v tmux >/dev/null 2>&1; then
  clone_if_missing https://github.com/tmux-plugins/tpm "$TPM_DIR"
  tmux_tmpdir="$(mktemp -d)"
  env -u TMUX TMUX_TMPDIR="$tmux_tmpdir" tmux new-session -d -s dotfiles-install
  if env -u TMUX TMUX_TMPDIR="$tmux_tmpdir" \
      GIT_TERMINAL_PROMPT=0 \
      GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0= \
      "$TPM_DIR/bin/install_plugins" >/dev/null; then
    tpm_ok=1
  else
    tpm_ok=0
  fi
  env -u TMUX TMUX_TMPDIR="$tmux_tmpdir" tmux kill-server
  rm -rf "$tmux_tmpdir"
  if [ "$tpm_ok" = 1 ]; then
    echo "installed tmux plugins"
  else
    echo "tmux plugin install failed" >&2
    exit 1
  fi
else
  echo "skipped tmux plugins (tmux not installed)"
fi
