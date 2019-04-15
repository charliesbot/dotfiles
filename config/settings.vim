"*****************************************************************************
"" Settings
"*****************************************************************************
set termguicolors                     " enable true colors
set hidden
set nopaste

" Indentation
set expandtab
set shiftwidth=2
set softtabstop=2

set splitright                        " vsplit at right side"
set cursorline
set number
set wildmode=longest:list,full        " command line completion
set whichwrap=b,s,h,l,<,>,[,]         " backspace and cursor keys wrap too
set showmatch                         " highlight matching parenthesis

" searching
set ignorecase                        " set case insensitive searching
set smartcase                         " case sensitive searching when not all lowercase
set inccommand=split                  " Live replacing using %s/text/newText

set mouse=a                           " Set mouse support

" background processes
" set clipboard=unnamed                 " use native clipboard
set clipboard^=unnamedplus
" set lazyredraw                        " no unneeded redraws
" set nolazyredraw
set nobackup                          " don't save backups
set noerrorbells                      " no error bells please
set noswapfile                        " no swapfiles

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" always show signcolumns
set signcolumn=yes

set completeopt-=preview

" Folds
set foldmethod=syntax
" set foldcolumn=1
set foldlevelstart=99

" Coc enhancements
set cmdheight=1
set updatetime=300
