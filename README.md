# dotfiles

## Bash

Clone the contents of this repo into: ~/dotfiles:
```
git clone https://github.com/sarink/dotfiles.git ~/dotfiles
```

Add the following to ~/.bash_profile
```
# Loads dotfiles (customize the list below accordingly)
for file in ~/dotfiles/.{base,brew,brew-bash-completion,docker,macos,nvm,tmux-completion}; do
  [ -r "$file" ] && source "$file"
done
unset file
```

_Note: If you are on a machine that doesn't have git bash completion, you can add git-completion to the list above,
it's probably slightly outdated, but better than nothing_

## Vim
Create a symbolic link for the vimrc config
```
ln -s ~/dotfiles/.vimrc ~/.vimrc
```

Clone vundle
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Open vim, run `:VundleInstall` to install vim plugins (official [vundle docs](https://github.com/VundleVim/Vundle.vim)

## Tmux
Create a symbolic link for the tmux config
```
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

Clone tmux plugin manager into: ~/dotfiles/.tmux/plugins/tpm
```
git clone git@github.com:tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Open tmux, run `<prefix>I` (probably `ctrl-aI`) to install tmux plugins (official [tpm docs](https://github.com/tmux-plugins/tpm)

