" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Fix terminal escape sequences on exit
set t_RV=      " Disable terminal version reporting
set t_SH=      " Disable shell escape codes
set t_TE=      " Disable exit termcap codes
set t_TI=      " Disable enter termcap codes

" Enable syntax highlighting
syntax enable

" Set encoding to UTF-8
set encoding=utf-8

" Set color scheme (try 'desert', 'slate', or install others)
colorscheme desert
"colorscheme molokai

" Show line numbers
"set number

" Highlight current line
set cursorline

" Auto-indent new lines
set autoindent

" Show matching brackets
set showmatch
hi MatchParen cterm=bold ctermbg=none ctermfg=214

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Tab settings (4 spaces)
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab

" Paste mode toggle (F2 to toggle)
set pastetoggle=<F2>

" Auto-enable paste mode when starting Vim
"autocmd VimEnter * set paste
autocmd InsertEnter * setlocal paste    " Enable paste mode when entering insert mode
autocmd InsertLeave * setlocal nopaste  " Disable paste mode when leaving insert mode

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Better search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Status line always visible
set laststatus=2

" Filetype detection and plugins
filetype plugin on
filetype indent on

" Backup and swap files
set nobackup
set nowritebackup
set noswapfile

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo

set wildmenu    " Better command-line completion
set showcmd     " Show partial commands in the last line of the screen
set ruler       " Display the cursor position on the last line of the screen or in the status line of a window
set laststatus=2        " Always display the status line, even if only one window is displayed
set updatetime=300 " Faster completion
set nostartofline " Keep cursor's column
behave xterm     " Set behavior to xterm, not mswin
set wrap         " Enable line wrapping

nnoremap :q :confirm q<CR>   " Remap :q to :confirm quit

filetype plugin on  " Enable file type detection
highlight Comment ctermfg=green  " Change comment color in terminal
highlight Comment guifg=#00FF00  " Change comment color in GUI
autocmd FileType python syntax on   " Enable syntax highlighting for Python files specifically
autocmd FileType sh syntax on       " Enable syntax highlighting for Bash files specifically
autocmd FileType perl syntax on         " Enable syntax highlighting for Perl files
autocmd FileType php syntax on          " Enable syntax highlighting for PHP files
nnoremap <F3> :set invsyntax<CR>    " Press F3 to toggle syntax highlighting
