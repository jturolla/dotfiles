set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
  Plugin 'VundleVim/Vundle.vim'

  Plugin 'kien/ctrlp.vim'
  let g:ctrlp_root_markers=['.ctrlp-root']
  let g:ctrlp_working_path_mode = 'ra'
  let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\'

  Plugin 'godlygeek/tabular'

  Plugin 'avakhov/vim-yaml'

  Plugin 'tpope/vim-fireplace'

  Plugin 'flazz/vim-colorschemes'

  Plugin 'junegunn/rainbow_parentheses.vim'
  let g:rainbow_active = 1
  let g:rainbow#colors = {
  \   'dark': [
  \     ['yellow',  'orange1'     ],
  \     ['green',   'yellow1'     ],
  \     ['cyan',    'greenyellow' ],
  \     ['magenta', 'green1'      ],
  \     ['red',     'springgreen1'],
  \     ['yellow',  'cyan1'       ],
  \     ['green',   'slateblue1'  ],
  \     ['cyan',    'magenta1'    ],
  \     ['magenta', 'purple1'     ]
  \   ],
  \   'light': [
  \     ['yellow',  'orange1'     ],
  \     ['green',   'yellow1'     ],
  \     ['cyan',    'greenyellow' ],
  \     ['magenta', 'green1'      ],
  \     ['red',     'springgreen1'],
  \     ['yellow',  'cyan1'       ],
  \     ['green',   'slateblue1'  ],
  \     ['cyan',    'magenta1'    ],
  \     ['magenta', 'purple1'     ]
  \   ]
  \ }
  augroup rainbow_lisp
    autocmd!
    autocmd FileType lisp,clojure,scheme RainbowParentheses
  augroup END

  Plugin 'terryma/vim-smooth-scroll'
  set scroll=15
  noremap <silent> <C-U> :call smooth_scroll#up(&scroll, 12, 1)<CR>
  noremap <silent> <C-D> :call smooth_scroll#down(&scroll, 12, 1)<CR>
  noremap <silent> <C-B> :call smooth_scroll#up(&scroll*2, 12, 4)<CR>
  noremap <silent> <C-F> :call smooth_scroll#down(&scroll*2, 12, 4)<CR>

  Plugin 'tpope/vim-surround'

  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'
  let g:airline_theme='badwolf'

  Plugin 'fatih/vim-hclfmt'
call vundle#end()

filetype plugin indent on

syntax on

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set number
set noswapfile
set nowrap
set linebreak
set noincsearch

set textwidth=79

colorscheme busybee

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

if !has('nvim')
  set ttymouse=xterm2
endif
