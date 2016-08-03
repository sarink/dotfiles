# Loads custom shell dotfiles
for file in ~/.{vimrc,profile,osx,env_vars,path,aliases,functions,git-completion,sshuttle,americanspiritgraphics,happyfuncorp,worldsinglesnetwork}; do
  [ -r "$file" ] && source "$file"
done
unset file
