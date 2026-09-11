# ~/.zprofile — runs once for login shells, before .zshrc.
# Self-contained: safe to drop straight into ~ .

# Homebrew: sets PATH/MANPATH/INFOPATH and brew env vars. Probe the usual
# prefixes (Apple Silicon, Intel, user-local install) so this works on any Mac.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew "$HOME/homebrew/bin/brew"; do
  if [ -x "$_brew" ]; then
    eval "$("$_brew" shellenv)"
    break
  fi
done
unset _brew
