""" Basic Settings """
" Enable syntax highlighting
syntax enable

" Set tabs to be 4 spaces
set tabstop=4
set shiftwidth=4
set expandtab

" Show line numbers
"set number

" Set encoding to UTF-8
set encoding=utf-8

" Enable mouse support (optional)
set mouse=a

" Set backup and swap files location
set backup
set backupdir=~/.vim/backups
set directory=~/.vim/swaps

set wildmenu    " Better command-line completion
set showcmd     " Show partial commands in the last line of the screen
set ruler       " Display the cursor position on the last line of the screen or in the status line of a window
set laststatus=2        " Always display the status line, even if only one window is displayed

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set hidden


""" Appearance """
" Set a nice color scheme
colorscheme desert

" Highlight current line
set cursorline

" Show matching parentheses
set showmatch

" Highlight search results
set hlsearch

" Show partial commands in the last line of the screen
set showcmd


""" Editing Features """
" Enable incremental search
set incsearch

" Ignore case when searching
set ignorecase

" Smart case-sensitive search when using capitals
set smartcase

" Enable auto-indentation
set autoindent

" Enable line wrapping
set wrap


""" Mapping and Key Bindings """
" Map <F2> to toggle paste mode
set pastetoggle=<F2>

" Map <Space> to clear search highlighting
nnoremap <Space> :nohlsearch<CR>

" Remap :q to :confirm quit
nnoremap :q :confirm q<CR>

" Map jk to escape in insert mode
inoremap jk <Esc>


""" Miscellaneous """
" Disable swap files (if desired)
set noswapfile

" Set backspace behavior
set backspace=indent,eol,start

" Enable spell check (if needed)
" set spell spelllang=en_us
