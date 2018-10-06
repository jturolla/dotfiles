set history=5000

filetype plugin on
filetype indent on

let mapleader = ","

set autoread
set expandtab
set history=500
set linebreak
set noincsearch
set noswapfile
set nowrap
set number
set relativenumber
set ruler
set so=7
set softtabstop=2
set tabstop=2
set textwidth=79
set wildmenu
set hid

set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

nmap <leader>w :w!<cr>
command W w !sudo tee % > /dev/null

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

filetype plugin on
filetype indent on

fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  :silent! %s/\s\+$//e
	:silent! %s#\($\n\s*\)\+\%$##
  call cursor(l, c)
endfun

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
