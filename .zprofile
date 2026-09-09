# ~/.zprofile — runs once for login shells, before .zshrc.
# Self-contained: safe to drop straight into ~ .

# Homebrew (Apple Silicon): sets PATH/MANPATH/INFOPATH and brew env vars.
eval "$(/opt/homebrew/bin/brew shellenv)"
