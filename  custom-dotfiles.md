custom-dotfiles

README
--------
1. Clone the contents of this repo into: ~/custom-dotfiles

2. Add a ~/.vimrc file with the following: `source ~/custom-dotfiles/.vimrc`

3. Add the following to ~/.bash_profile:
```
# Loads custom shell dotfiles
for file in ~/custom-dotfiles/.{base,rvm,osx,unix_nvm,brew_nvm,docker,git-completion,git-utils,sshuttle,americanspiritgraphics,happyfuncorp,worldsinglesnetwork,verizon}; do
  [ -r "$file" ] && source "$file"
done
unset file
```
