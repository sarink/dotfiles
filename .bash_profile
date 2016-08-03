# Load custom shell dotfiles
for file in ~/custom_dotfiles/.{.osx,env_vars,path,aliases,functions,git-completion,sshuttle,americanspiritgraphics,happyfuncorp,worldsinglesnetwork}; do
  [ -r "$file" ] && source "$file"
done
unset file

export PS1="\[\e[34;0m\]\u@\h:\W \$(parse_git_branch)\\$ \[\e[0m\]"