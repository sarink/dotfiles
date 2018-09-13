" You just always do this. It has to do w/ vi compatability maybe
set nocompatible

" Turn on syntax highlighting
syntax on

" Use system clipboard
set clipboard=unnamed

" Show what's happening in the bottom right corner
set showcmd

" Turn on syntax highlighting
syntax on

" Show what's happening in the bottom right corner
set showcmd

" Disable automatic visual mode on mouse select
set mouse-=a

" Enter 'jj' in insert mode to return to normal mode
inoremap jj <ESC>

" Allow hidden buffers
set hidden

" Always show tab listing, even if only 1 tab is open
set showtabline=2
" Ctrl-n and Ctrl-p to move to next and previous tab
nnoremap <C-n> :tabn<CR>
nnoremap <C-p> :tabp<CR>

" Highlight search results
set hlsearch
nnoremap <C-h> :noh<CR>

" Line numbers
set number

" Show row & column in statusbar
set ruler
set colorcolumn=101

" Set location for backup and swap files, respectively
set backupdir=./.backup,/tmp//,.
set directory=./.backup,/tmp//,.

" Lots of stuff for indents and text width
set tabstop=4
set shiftwidth=4
set nowrap
set textwidth=150
set formatoptions=tcq
set ai
set copyindent
set smarttab
set expandtab

" Get menu for autocompletes like :find
set wildmenu

" Don't look into node_modules - there's a zillion files in there and I (usually) don't care about any of them
set wildignore+=*/node_modules/*

" Allow backspacing over all kinds of stuff
set backspace=indent,eol,start

" Add a small scroll-off value so there's always a few lines above & below the cursor
set scrolloff=4

" open splits below or to the right of the current window - the default top/left is weird
set splitbelow
set splitright

" Path is directory of current file, working directory, and recursive search from working directory
set path=.,,**

" Hm
filetype on
filetype plugin on
filetype indent on

" Language-specific 
autocmd FileType html,ruby,eruby,css,scss setlocal sw=2 ts=2 tw=0
autocmd FileType javascript,javascript.jsx setlocal sw=2 ts=2 tw=100

" Automatic text wrapping at col 80 for git commits
autocmd FileType gitcommit setlocal tw=80 colorcolumn=81



" Vundle!
set rtp+=~/custom-dotfiles/vundle/Vundle.vim
call vundle#begin('~/custom-dotfiles/vundle')
Plugin 'VundleVim/Vundle.vim'
Plugin 'dracula/vim'
Plugin 'vim-airline/vim-airline'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-syntastic/syntastic'
call vundle#end()
filetype plugin indent on

" Use dracula color scheme
color dracula
