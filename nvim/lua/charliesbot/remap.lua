-- vim.keymap.set mode, shortcut, action, config
local opts = { noremap = true, silent = true }

vim.keymap.set("i", "jj", "<ESC>", opts)
vim.keymap.set("n", "<leader>V", ":vsplit<CR>", opts)

-- Clear search highlight
vim.keymap.set("n", "<esc>", ":noh<return><esc>", opts)

-- Fold
vim.keymap.set("n", "zC", "zM", opts)
vim.keymap.set("n", "zO", "zR", opts)
vim.keymap.set("n", "zz", "<C-w>|", opts)

-- Indentations
vim.keymap.set("v", ">", ">gv", { silent = true })
vim.keymap.set("v", "<", "<gv", { silent = true })
