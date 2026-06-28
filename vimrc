set nocompatible
set tabstop=2
set shiftwidth=2
set expandtab
set softtabstop=2
set number
set encoding=utf-8
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
colorscheme desert  " Set a nice color scheme
set cursorline   " Highlight current line
set showmatch    " Show matching parentheses
set hlsearch     " Highlight search results
highlight Search ctermfg=black ctermbg=green guifg=black guibg=green " Customize the highlight for search results
set background=dark " Use dark background (change to light for light theme)
set incsearch    " Enable incremental search
set ignorecase   " Ignore case when searching
set smartcase    " Smart case-sensitive search when using capitals
set autoindent   " Enable auto-indentation
set wrap         " Enable line wrapping
set backspace=indent,eol,start  " Enable backspace behavior, allow backspacing over everything in insert mode
if has('mouse')
  set mouse=a
endif
set pastetoggle=<F2>     " Map <F2> to toggle paste mode manually
inoremap jk <Esc>    " Map jk to escape in insert mode
syntax on   " Enable syntax highlighting globally
filetype plugin indent on  " Enable file type detection, plugins, and indentation
highlight Comment ctermfg=green  " Change comment color in terminal
highlight Comment guifg=#00FF00  " Change comment color in GUI
nnoremap <F3> :set invsyntax<CR>    " Press F3 to toggle syntax highlighting
set termguicolors              " Enable true color support
set completeopt=menuone,noinsert,noselect  " Better autocomplete
set wildignore=*.o,*.pyc,*.swp,*.bak,*.class  " Ignore these files in completion
set list listchars=tab:»·,trail:·  " Show invisible characters
set colorcolumn=80              " Show column guide
