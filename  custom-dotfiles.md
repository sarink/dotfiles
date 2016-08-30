custom-dotfiles

README
--------
1. Clone the contents of this repo into: ~/custom-dotfiles

2. Add a ~/.vimrc file with the following: `source ~/custom-dotfiles/.vimrc`

3. Add the following to ~/.bash_profile:
```
# Loads custom shell dotfiles
for file in ~/custom-dotfiles/.{profile,rvm,osx,env_vars,brew_nvm,path,aliases,functions,git-completion,sshuttle,americanspiritgraphics,happyfuncorp,worldsinglesnetwork,verizon}; do
  [ -r "$file" ] && source "$file"
done
unset file
```
