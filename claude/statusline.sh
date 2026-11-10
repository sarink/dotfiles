#!/bin/bash
# Renders "<session> | <model> | Free space: <Xk> (<Y>%)" and optionally "| Effort: <level>"
# and "| PR #<n>", a clickable link to the current branch's open PR.
# Session name comes from session_name when set via /rename, otherwise falls
# back to the first 8 characters of session_id.
# Free-space counts cache_read + cache_creation + new input tokens so it
# matches the /context display.
set -euo pipefail

input=$(cat)

session=$(printf '%s' "$input" | jq -r '
  if .session_name and (.session_name | length) > 0
  then .session_name
  else (.session_id // "" | .[0:8])
  end
')

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')

read -r size used < <(printf '%s' "$input" | jq -r '
  .context_window
  | "\(.context_window_size // 0) \((.current_usage.input_tokens // 0)
      + (.current_usage.cache_creation_input_tokens // 0)
      + (.current_usage.cache_read_input_tokens // 0))"
')

effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')

# gh takes ~0.5s, so the open-PR lookup is cached per directory and branch for a minute.
pr=""
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null); then
  cache="${TMPDIR:-/tmp}/claude-statusline-pr${dir//\//_}@${branch//\//_}"
  if [[ -z $(find "$cache" -mmin -1 2>/dev/null) ]]; then
    # A failed lookup keeps the last answer instead of hiding the PR.
    if out=$(cd "$dir" && gh pr view --json number,url,state -q 'select(.state == "OPEN") | "\(.number) \(.url)"' 2>"$cache.err"); then
      printf '%s\n' "$out" > "$cache"
    elif grep -q 'no pull requests found' "$cache.err"; then
      : > "$cache"
    else
      touch "$cache"
    fi
  fi
  if read -r num url < "$cache"; then
    pr=$(printf '\e]8;;%s\e\\PR #%s\e]8;;\e\\' "$url" "$num")
  fi
fi

if [[ -z "$size" || "$size" -eq 0 ]]; then
  space="Free space: ?"
else
  free=$((size - used))
  space=$(awk -v f="$free" -v s="$size" 'BEGIN { printf "Free space: %.1fk (%.1f%%)", f / 1000, f * 100 / s }')
fi

prefix=""
[[ -n "$session" ]] && prefix="${session} | "
[[ -n "$model" ]] && prefix="${prefix}${model} | "

suffix=""
[[ -n "$effort" ]] && suffix=" | Effort: ${effort}"
[[ -n "$pr" ]] && suffix="${suffix} | ${pr}"
printf '%s%s%s\n' "$prefix" "$space" "$suffix"
