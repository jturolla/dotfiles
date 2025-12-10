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
set ruler
set so=7
set softtabstop=2
set tabstop=2
set shiftwidth=2
"set textwidth=79
set wildmenu
set hid
set ignorecase
set smartcase
set lazyredraw
set showmatch
set laststatus=2
syntax enable

colorscheme desert

set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.md setlocal textwidth=79

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

autocmd BufWritePre * :call CleanWhitespace()

map <leader>q :e ~/buffer<cr>
map <leader>pp :setlocal paste!<cr>

set grepprg=rg\ --color=never
let g:ctrlp_user_command = 'rg %s --files --color=never --hidden --glob "!.git"'
let g:ctrlp_use_caching = 1
let g:ctrlp_working_path_mode = 0
let g:ctrlp_lazy_update = 1

set statusline=\%F%m%r%h\ %w

let g:terraform_align=1
let g:terraform_fold_sections=1

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0#
let g:indentLine_char = '⦙'

let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.git$', '\.idea$', '\.vscode$', '\.history$']
