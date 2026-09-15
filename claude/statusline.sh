#!/bin/bash
# Renders "<session> | <model> | Free space: <Xk> (<Y>%)" and optionally "| Effort: <level>".
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

if [[ -z "$size" || "$size" -eq 0 ]]; then
  space="Free space: ?"
else
  free=$((size - used))
  space=$(awk -v f="$free" -v s="$size" 'BEGIN { printf "Free space: %.1fk (%.1f%%)", f / 1000, f * 100 / s }')
fi

prefix=""
[[ -n "$session" ]] && prefix="${session} | "
[[ -n "$model" ]] && prefix="${prefix}${model} | "

if [[ -n "$effort" ]]; then
  printf '%s%s | Effort: %s\n' "$prefix" "$space" "$effort"
else
  printf '%s%s\n' "$prefix" "$space"
fi
