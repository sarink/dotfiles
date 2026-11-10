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

for f in $FILES; do
  install_file "$DOTFILES_DIR/$f" "$HOME/$f"
done

# Agent config: claude/ and codex/ mirror ~/.claude/ and ~/.codex/.
for agent in claude codex; do
  cd "$DOTFILES_DIR/$agent"
  find . -type f ! -name .DS_Store | while IFS= read -r f; do
    case "$agent/${f#./}" in
      claude/settings.json) merge_json_defaults "$DOTFILES_DIR/$agent/${f#./}" "$HOME/.$agent/${f#./}" ;;
      codex/config.toml) merge_toml_defaults "$DOTFILES_DIR/$agent/${f#./}" "$HOME/.$agent/${f#./}" ;;
      *) install_file "$DOTFILES_DIR/$agent/${f#./}" "$HOME/.$agent/${f#./}" ;;
    esac
  done
done
