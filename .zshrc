# ~/.zshrc — interactive zsh configuration.
# Symlink with: ln -s ~/dotfiles/.zshrc ~/.zshrc

# Personal bin on PATH
export PATH="$HOME/.local/bin:$PATH"

##########################################
# Completion
##########################################
# Native zsh completions replace the old vendored bash completion files.
# Put Homebrew's zsh completions on $fpath before compinit; bashcompinit is a
# compatibility shim for the rare tool that only ships a bash completion.
if (( $+commands[brew] )); then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

##########################################
# Shared dotfiles (shell-agnostic: env vars, aliases, functions)
##########################################
for file in ~/dotfiles/.{base,docker,macos}; do
  [ -r "$file" ] && source "$file"
done
unset file

##########################################
# Version manager (Node, Ruby, Python via mise)
##########################################
# Replaces nvm/rbenv/pyenv. Honors .nvmrc/.ruby-version/.python-version.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

##########################################
# Prompt — native zsh, replaces the old bash PS1 in .base
##########################################
# user@host:dir (git-branch). vcs_info computes the branch without forking git.
autoload -Uz vcs_info
setopt PROMPT_SUBST
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b) '
PROMPT='%F{blue}%n@%m:%1~ ${vcs_info_msg_0_}%#%f '
