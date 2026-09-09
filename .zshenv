# ~/.zshenv — sourced by EVERY zsh invocation (interactive, non-interactive,
# login, and non-login). `mise activate` lives in .zshrc and only runs in
# interactive shells, so scripts (#!/bin/bash), IDE tasks, and other
# non-interactive shells lose node/npm/npx/etc. Putting mise's shims on PATH
# here fixes that globally. Shims auto-select the right tool version per
# directory (.nvmrc, mise.toml, .tool-versions). Child processes inherit this
# exported PATH, so scripts launched from the terminal get the tools too.
if [ -d "$HOME/.local/share/mise/shims" ]; then
  case ":$PATH:" in
    *":$HOME/.local/share/mise/shims:"*) ;;  # already present, don't duplicate
    *) export PATH="$HOME/.local/share/mise/shims:$PATH" ;;
  esac
fi
