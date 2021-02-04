-- Leader
vim.cmd('let mapleader=" "')

vim.cmd("set termguicolors" )
vim.cmd("set hidden" )
vim.cmd("set nopaste" )

-- Indentation
vim.cmd("set expandtab" )
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- vsplit at right side"
vim.cmd("set splitright")
vim.cmd("set cursorline")
vim.cmd("set number")
-- command line completion
vim.cmd("set wildmode=longest:list,full")
-- backspace and cursor keys wrap too
vim.cmd("set whichwrap=b,s,h,l,<,>,[,]")
-- highlight matching parenthesis
vim.cmd("set showmatch")

-- set case insensitive searching
vim.cmd("set ignorecase")
-- case sensitive searching when not all lowercase
vim.cmd("set smartcase")
-- Live replacing using %s/text/newText
vim.cmd("set inccommand=split")

vim.cmd("set mouse=a")

-- use native clipboard
vim.cmd("set clipboard^=unnamedplus")

vim.cmd("set nobackup")
vim.cmd("set noerrorbells")
vim.cmd("set noswapfile")

vim.cmd("set encoding=utf-8")
vim.cmd("set fileencoding=utf-8")
vim.cmd("set fileencodings=utf-8")

-- Always show signcolumns
vim.cmd("set signcolumn=yes")

vim.cmd("set completeopt-=preview")

-- Folds
vim.cmd("set foldmethod=syntax")
vim.cmd("set foldlevelstart=99")

-- Coc enhancements
vim.cmd("set cmdheight=1")
vim.cmd("set updatetime=300")
