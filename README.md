custom-dotfiles

README
--------
1. Clone the contents of this repo into: ~/custom-dotfiles:
```
git clone https://gist.github.com/268d57f66ca1ffafe07b30fbe30434eb.git ~/custom-dotfiles
```

2. Clone vundle into: ~/custom-dotfiles/vundle/Vundle.vim
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/custom-dotfiles/vundle/Vundle.vim
```

3. Add a ~/.vimrc file that sources the ~/custom-dotfiles/.vimrc
```
echo "source ~/custom-dotfiles/.vimrc" >> ~/.vimrc 
```

4. Open vim, run `:VundleInstall`

5. Create a symbolic link for the tmux config
```
ln -s ~/custom-dotfiles/.tmux.conf ~/.tmux.conf
```

6. Add the following to ~/.bash_profile (once vim is open, first execute `:VundleInstall` to install plugins)
```
# Loads custom shell dotfiles (customize the list below accordingly)
for file in ~/custom-dotfiles/.{base,git-completion,git-utils}; do
  [ -r "$file" ] && source "$file"
done
unset file
```