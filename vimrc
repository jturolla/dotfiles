set history=5000

filetype plugin on
filetype indent on

let mapleader = ","

set autoread
set autoindent
set smartindent
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
set shiftwidth=2
set textwidth=79
set wildmenu
set hid
set ignorecase
set smartcase
set lazyredraw
set showmatch
set laststatus=2
set undodir=~/.vim_undo_history
set undofile
syntax enable

call plug#begin('~/.vim/plugged')
 Plug 'mileszs/ack.vim'
call plug#end()

let g:ackprg = 'rg --vimgrep'

colorscheme desert

set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

filetype plugin on
filetype indent on

fun! CleanWhitespace()
  let last_position= getpos(".")
  let old_query = getreg("/")

  silent! %s/\s\+$//g
	silent! %s/\($\n\s*\)\+\%$//g

  call setpos('.', last_position)
  call setreg('/', old_query)
endfun

fun! HasPaste()
  if &paste
    return 'PASTE '
  endif
  return ''
endfunction


autocmd BufWritePre * :call CleanWhitespace()

map <leader>q :e ~/buffer<cr>
map <leader>x :e ~/buffer<cr>
map <leader>pp :setlocal paste!<cr>
nmap <leader>w :w!<cr>
command! W w !sudo tee % > /dev/null
map <leader>r :source ~/.vimrc<cr>
cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>

set statusline=\%{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
