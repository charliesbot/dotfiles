-- keymap mode, shortcut, action, config
local keymap = vim.api.nvim_set_keymap

-- *****************************************************************************
-- Mappings
-- *****************************************************************************
keymap('', '<C-b>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
keymap('i', 'jj', '<ESC>', { noremap = true, silent = true })
keymap('n', '<leader>V', ':vsplit<CR>', { noremap = true, silent = true })
-- Clear search highlight
keymap('n', '<esc>', ':noh<return><esc>', { noremap = true, silent = true })

-- *****************************************************************************
-- LSP
-- *****************************************************************************

vim.cmd("command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)")

vim.cmd([[
command! -bang -nargs=? -complete=dir Files
call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
]])

keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
keymap('n', '<C-f>', ':Find<CR>', { noremap = true, silent = true })

-- *****************************************************************************
-- LSP
-- *****************************************************************************
keymap('n', 'gd', '<Plug>(coc-definition)', { silent = true })
keymap('n', 'gh', ":call CocAction('doHover')<CR>", { noremap = true, silent = true })
keymap('n', 'gD', ":call CocAction('jumpDefinition', 'vsplit')<CR>", { silent = true })
keymap('n', '<leader>m', '<Plug>(coc-diagnostic-next)', { silent = true })
keymap('n', '<leader>n', '<Plug>(coc-diagnostic-next)', { silent = true })
keymap('n', '<leader>rn', '<Plug>(coc-rename)', { silent = true })
-- Use <c-space> to trigger completion.
keymap('i', '<C-Space>', 'coc#refresh()', { noremap = true, silent = true, expr = true })
vim.fn.nvim_set_keymap('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { noremap = true, expr = true })
vim.fn.nvim_set_keymap('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { noremap = true, expr = true })
-- Highlight symbol under cursor on CursorHold
--autocmd CursorHold * silent call CocActionAsync('highlight')

-- *****************************************************************************
-- Fold
-- *****************************************************************************
keymap('n', 'zC', 'zM', { noremap = true, silent = true })
keymap('n', 'zO', 'zR', { noremap = true, silent = true })
keymap('n', 'zz', '<C-w>|', { noremap = true, silent = true })

-- *****************************************************************************
-- Comments
-- *****************************************************************************
keymap('', 'gcc', '<Plug>NERDCommenterToggle', { noremap = false, silent = true })

-- *****************************************************************************
-- Indentations
-- *****************************************************************************
-- Have the indent commands re-highlight the last visual selection to make
-- multiple indentations easier
keymap('v', '>', '>gv', { silent = true })
keymap('v', '<', '<gv', { silent = true })

-- *****************************************************************************
-- Sneak
-- *****************************************************************************
keymap('n', 'f', '<Plug>Sneak_f', { silent = true })
keymap('n', 'F', '<Plug>Sneak_F', { silent = true })
keymap('x', 'f', '<Plug>Sneak_f', { silent = true })
keymap('x', 'F', '<Plug>Sneak_F', { silent = true })
keymap('o', 'f', '<Plug>Sneak_f', { silent = true })
keymap('o', 'F', '<Plug>Sneak_F', { silent = true })

-- *****************************************************************************
-- Open Configs
-- *****************************************************************************
keymap('n', '<leader>ev', ':tabe ~/.config/nvim/init.lua<CR>', { noremap = true, silent = true })
keymap('n', '<leader>es', ':tabe ~/.config/nvim/coc-settings.json<CR>', { noremap = true, silent = true })
keymap('n', '<leader>et', ':tabe ~/.tmux.conf<CR>', { noremap = true, silent = true })
keymap('n', '<leader>eg', ':tabe ~/.gitconfig<CR>', { noremap = true, silent = true })
keymap('n', '<leader>ec', ':tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>', { noremap = true, silent = true })

-- *****************************************************************************
-- Git
-- *****************************************************************************
keymap('n', '<leader>c', "<ESC>/\v^[<=>]{7}( .*|$)<CR>", { noremap = true, silent = true })

