# dotfiles

1. Clone the contents of this repo into: ~/dotfiles:
```
git clone git@github.com:sarink/dotfiles.git ~/dotfiles
```

1. Add the following to ~/.bash_profile
```
# Loads dotfiles (customize the list below accordingly)
for file in ~/dotfiles/.{base,git-completion,tmux-completion}; do
  [ -r "$file" ] && source "$file"
done
unset file
```

1. Clone vundle
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

1. Create a symbolic link for the vimrc config
```
ln -s ~/dotfiles/.vimrc ~/.vimrc
```

1. Open vim, run `:VundleInstall` to install vim plugins (official [vundle docs](https://github.com/VundleVim/Vundle.vim)

1. Create a symbolic link for the tmux config
```
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

1. Clone tmux plugin manager into: ~/dotfiles/.tmux/plugins/tpm
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

1. Open tmux, run `<prefix>I` (probably `ctrl-aI`) to install tmux plugins (official [tpm docs](https://github.com/tmux-plugins/tpm)

