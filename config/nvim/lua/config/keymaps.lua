-- The single home for plugin-independent keymaps.
-- Plugin-backed keys (picker, explorer, Git, LSP) live with their plugin.

local map = vim.keymap.set

-- Clear search highlight on Esc.
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics. `jump` replaces the deprecated goto_next / goto_prev.
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map('n', '<leader>n', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to [N]ext diagnostic' })
map('n', '<leader>m', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous ([M]) diagnostic' })

-- Window focus.
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

-- Vertical splits.
map('n', '<leader>v', '<cmd>vsplit<CR>', { desc = 'Vertical split current buffer' })
map('n', '<leader>V', '<cmd>vnew<CR>', { desc = 'Vertical split with new buffer' })

-- Move lines up / down.
map('n', '<C-k>', ':move .-2<CR>==', { desc = 'Move line up', silent = true })
map('n', '<C-j>', ':move .+1<CR>==', { desc = 'Move line down', silent = true })
map('v', '<C-k>', ":move '<-2<CR>gv=gv", { desc = 'Move selection up', silent = true })
map('v', '<C-j>', ":move '>+1<CR>gv=gv", { desc = 'Move selection down', silent = true })

-- Exit terminal mode with a friendlier chord.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
