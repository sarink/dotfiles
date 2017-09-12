custom-dotfiles

README
--------
1. Clone the contents of this repo into: ~/custom-dotfiles:
```
git clone https://gist.github.com/268d57f66ca1ffafe07b30fbe30434eb.git ~/custom-dotfiles
```

2. Clone vundle (for vim):
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/custom-dotfiles/vundle/Vundle.vim
```

3. Add a ~/.vimrc file with the following: `source ~/custom-dotfiles/.vimrc`

4. Add the following to ~/.bash_profile:
```
# Loads custom shell dotfiles
for file in ~/custom-dotfiles/.{base,rvm,osx,unix_nvm,docker,git-completion,git-utils}; do
  [ -r "$file" ] && source "$file"
done
unset file
```
