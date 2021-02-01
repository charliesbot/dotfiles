-- keymap mode, shortcut, action, config
local keymap = vim.api.nvim_set_keymap

-- *****************************************************************************
-- Mappings
-- *****************************************************************************
keymap('', '<C-b>', ':NERDTreeToggle<CR>', { noremap = true, silent = true})
keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true})
keymap('n', '<C-f>', ':Find<CR>', { noremap = true, silent = true})
keymap('n', '<C-f>', ':Find<CR>', { noremap = true, silent = true})
keymap('i', 'jj', '<ESC>', { noremap = true, silent = true})
keymap('n', '<leader>V', ':vsplit<CR>', { noremap = true, silent = true})
-- Clear search highlight
keymap('n', '<esc>', ':noh<return><esc>', { noremap = true, silent = true})

-- *****************************************************************************
-- LSP
-- *****************************************************************************
keymap('n', 'gD', ":call CocAction('jumpDefinition', 'vsplit')<CR>", { noremap = true, silent = true})
keymap('n', '<leader>rn', '<Plug>(coc-rename)', { noremap = true, silent = true})
keymap('n', 'gd', '<Plug>(coc-definition)', { noremap = true, silent = true})
keymap('n', 'gh', ":call CocAction('doHover')<CR>", { noremap = true, silent = true})
keymap('n', '<leader>m', '<Plug>(coc-diagnostic-prev)', { noremap = true, silent = true})
keymap('n', '<leader>n', '<Plug>(coc-diagnostic-next)', { noremap = true, silent = true})
-- Use <c-space> to trigger completion.
keymap('n', '<c-space>', 'coc#refresh()', { noremap = true, silent = true})

-- Highlight symbol under cursor on CursorHold
--autocmd CursorHold * silent call CocActionAsync('highlight')

-- *****************************************************************************
-- Fold
-- *****************************************************************************
keymap('n', 'zC', 'zM', { noremap = true, silent = true})
keymap('n', 'zO', 'zR', { noremap = true, silent = true})
keymap('n', 'zz', '<C-w>|', { noremap = true, silent = true})

-- *****************************************************************************
-- Comments
-- *****************************************************************************
keymap('', 'gcc', '<Plug>NERDCommenterToggle', { noremap = false, silent = true})

-- *****************************************************************************
-- Indentations
-- *****************************************************************************
-- Have the indent commands re-highlight the last visual selection to make
-- multiple indentations easier
keymap('v', '>', '>gv', { noremap = true, silent = true})
keymap('v', '<', '<gv', { noremap = true, silent = true})

-- *****************************************************************************
-- Sneak
-- *****************************************************************************
keymap('n', 'f', '<Plug>Sneak_f', { noremap = true, silent = true})
keymap('n', 'F', '<Plug>Sneak_F', { noremap = true, silent = true})
keymap('x', 'f', '<Plug>Sneak_f', { noremap = true, silent = true})
keymap('x', 'F', '<Plug>Sneak_F', { noremap = true, silent = true})
keymap('o', 'f', '<Plug>Sneak_f', { noremap = true, silent = true})
keymap('o', 'F', '<Plug>Sneak_F', { noremap = true, silent = true})

-- *****************************************************************************
-- Open Configs
-- *****************************************************************************
keymap('n', '<leader>ev', ':tabe ~/.config/nvim/init.vim<CR>', { noremap = true, silent = true})
keymap('n', '<leader>es', ':tabe ~/.config/nvim/coc-settings.json<CR>', { noremap = true, silent = true})
keymap('n', '<leader>et', ':tabe ~/.tmux.conf<CR>', { noremap = true, silent = true})
keymap('n', '<leader>eg', ':tabe ~/.gitconfig<CR>', { noremap = true, silent = true})
keymap('n', '<leader>ec', ':tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>', { noremap = true, silent = true})

-- *****************************************************************************
-- Git
-- *****************************************************************************
keymap('n', '<leader>c', "<ESC>/\v^[<=>]{7}( .*|$)<CR>", { noremap = true, silent = true})

