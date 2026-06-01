# ~/.zprofile — runs once for login shells, before .zshrc.
# Symlink with: ln -s ~/dotfiles/.zprofile ~/.zprofile
#
# Login-time setup that adjusts PATH belongs here. Reuses the same Homebrew
# snippet as the bash setup so there's a single source of truth.
[ -r ~/dotfiles/.brew ] && source ~/dotfiles/.brew
