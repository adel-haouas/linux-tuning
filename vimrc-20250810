" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

""" Basic Settings """

" Set tabs to be 4 spaces
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

" Show line numbers
"set number

" Set encoding to UTF-8
set encoding=utf-8

" Set backup and swap files location
"set backup
"set backupdir=~/.vim/backups
"set directory=~/.vim/swaps
if has("vms")
  set nobackup          " do not keep a backup file, use versions instead
else
  set backup            " keep a backup file
endif

set wildmenu    " Better command-line completion
set showcmd     " Show partial commands in the last line of the screen
set ruler       " Display the cursor position on the last line of the screen or in the status line of a window
set laststatus=2        " Always display the status line, even if only one window is displayed
set updatetime=300 " Faster completion
set nostartofline " Keep cursor's column
behave xterm     " Set behavior to xterm, not mswin

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set hidden

""" Appearance """
colorscheme desert  " Set a nice color scheme
set cursorline   " Highlight current line
set showmatch    " Show matching parentheses
set hlsearch     " Highlight search results
highlight Search ctermfg=black ctermbg=green guifg=black guibg=green " Customize the highlight for search results
set background=dark " Use dark background (change to light for light theme)

""" Editing Features """
set incsearch    " Enable incremental search
set ignorecase   " Ignore case when searching
set smartcase    " Smart case-sensitive search when using capitals
set autoindent   " Enable auto-indentation
set wrap         " Enable line wrapping
set backspace=indent,eol,start  " Enable backspace behavior, allow backspacing over everything in insert mode

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

""" Mapping and Key Bindings """
set pastetoggle=<F2>     " Map <F2> to toggle paste mode
nnoremap <Space> :nohlsearch<CR>     " Map <Space> to clear search highlighting
nnoremap :q :confirm q<CR>   " Remap :q to :confirm quit
inoremap jk <Esc>    " Map jk to escape in insert mode

""" Miscellaneous """
"set noswapfile   " Disable swap files (if desired)
autocmd InsertEnter * setlocal paste    " Enable paste mode when entering insert mode
autocmd InsertLeave * setlocal nopaste  " Disable paste mode when leaving insert mode

" Enable spell check (if needed)
" set spell spelllang=en_us

""" Syntax Highlighting """
syntax enable " Enable syntax highlighting
syntax on   " Enable syntax highlighting globally
filetype plugin on  " Enable file type detection
highlight Comment ctermfg=green  " Change comment color in terminal
highlight Comment guifg=#00FF00  " Change comment color in GUI
autocmd FileType python syntax on   " Enable syntax highlighting for Python files specifically
autocmd FileType sh syntax on       " Enable syntax highlighting for Bash files specifically
autocmd FileType perl syntax on         " Enable syntax highlighting for Perl files
autocmd FileType php syntax on          " Enable syntax highlighting for PHP files
nnoremap <F3> :set invsyntax<CR>    " Press F3 to toggle syntax highlighting

set statusline=%{fugitive#statusline()}
