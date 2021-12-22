# dotfiles

1. Clone the contents of this repo into: ~/dotfiles:
```
git clone git@github.com:sarink/dotfiles.git ~/dotfiles
```

2. Clone vundle into: ~/dotfiles/vundle/Vundle.vim
```
git clone git@github.com:VundleVim/Vundle.vim.git ~/dotfiles/vundle/Vundle.vim
```

3. Add a ~/.vimrc file that sources the ~/dotfiles/.vimrc
```
echo "source ~/dotfiles/.vimrc" >> ~/.vimrc 
```

4. Open vim, run `:VundleInstall`

5. Create a symbolic link for the tmux config
```
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

6. Add the following to ~/.bash_profile (once vim is open, first execute `:VundleInstall` to install plugins)
```
# Loads dotfiles (customize the list below accordingly)
for file in ~/dotfiles/.{base,git-completion,git-utils}; do
  [ -r "$file" ] && source "$file"
done
unset file
```
