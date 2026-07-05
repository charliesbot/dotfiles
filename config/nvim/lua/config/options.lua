-- Core editor options. See `:help vim.o` and `:help option-list`.

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
-- Wait time for a mapped sequence to complete. Widened from 300 so the
-- mini.surround s-prefix (sa/sd/sr) does not need to be typed in a rush.
vim.o.timeoutlen = 500
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Preview substitutions live as you type.
vim.o.inccommand = 'split'

-- Rounded borders on all floating windows (hover, diagnostics, signature, etc.).
vim.o.winborder = 'rounded'

-- Sync clipboard with the OS after UI starts, to keep startup fast.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Spaces, two wide, everywhere by default.
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
