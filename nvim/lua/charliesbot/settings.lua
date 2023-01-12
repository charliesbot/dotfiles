vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.hidden = true

vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.number = true

-- Indentation
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.wrap = false

-- highlight matching parenthesis
vim.opt.showmatch = true

-- set case insensitive searching
vim.opt.ignorecase = true
-- case sensitive searching when not all lowercase
vim.opt.smartcase = true
-- Live replacing using %s/text/newText
vim.opt.inccommand = "split"

vim.opt.mouse = "a"

-- use native clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.backup = false
vim.opt.errorbells = false
vim.opt.swapfile = false

-- Always show signcolumns
vim.opt.signcolumn = "yes"
