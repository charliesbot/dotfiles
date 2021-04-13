-- keymap mode, shortcut, action, config
local keymap = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

-- *****************************************************************************
-- Mappings
-- *****************************************************************************
keymap('', '<C-b>', ':NERDTreeToggle<CR>', opts)
keymap('i', 'jj', '<ESC>', opts)
keymap('n', '<leader>V', ':vsplit<CR>', opts)
-- Clear search highlight
keymap('n', '<esc>', ':noh<return><esc>', opts)

keymap('n', '<C-p>', ':Files<CR>', opts)
keymap('n', '<C-f>', ':Find<CR>', opts)

vim.cmd(
    "command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)")
vim.cmd([[
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
]])

-- *****************************************************************************
-- LSP
-- *****************************************************************************
keymap('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], {expr = true})
keymap('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], {expr = true})
keymap('n', 'gp', ':Lspsaga preview_definition<CR>', opts)
keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
keymap('n', 'gD', '<Cmd>vsplit | lua vim.lsp.buf.definition()<CR>', opts)
keymap('n', 'gh', ':Lspsaga hover_doc<CR>', opts)
-- keymap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
keymap('n', '<space>m', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
keymap('n', '<space>n', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
keymap('n', '<space>p', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)

-- *****************************************************************************
-- Fold
-- *****************************************************************************
<<<<<<< HEAD
<<<<<<< HEAD
keymap('n', 'zC', 'zM', opts)
keymap('n', 'zO', 'zR', opts)
keymap('n', 'zz', '<C-w>|', opts)
=======
keymap('n', 'zC', 'zM', {noremap = true, silent = true})
keymap('n', 'zO', 'zR', {noremap = true, silent = true})
keymap('n', 'zz', '<C-w>|', {noremap = true, silent = true})
>>>>>>> 178f39e (run format)
=======
keymap('n', 'zC', 'zM', opts)
keymap('n', 'zO', 'zR', opts)
keymap('n', 'zz', '<C-w>|', opts)
>>>>>>> a812a09 (add saga)

-- *****************************************************************************
-- Comments
-- *****************************************************************************
keymap('', 'gcc', '<Plug>NERDCommenterToggle', {noremap = false, silent = true})

-- *****************************************************************************
-- Indentations
-- *****************************************************************************
-- Have the indent commands re-highlight the last visual selection to make
-- multiple indentations easier
keymap('v', '>', '>gv', {silent = true})
keymap('v', '<', '<gv', {silent = true})

-- *****************************************************************************
-- Sneak
-- *****************************************************************************
keymap('n', 'f', '<Plug>Sneak_f', {silent = true})
keymap('n', 'F', '<Plug>Sneak_F', {silent = true})
keymap('x', 'f', '<Plug>Sneak_f', {silent = true})
keymap('x', 'F', '<Plug>Sneak_F', {silent = true})
keymap('o', 'f', '<Plug>Sneak_f', {silent = true})
keymap('o', 'F', '<Plug>Sneak_F', {silent = true})

-- *****************************************************************************
-- Open Configs
-- *****************************************************************************
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> a812a09 (add saga)
keymap('n', '<leader>ev', ':tabe ~/.config/nvim/init.lua<CR>', opts)
keymap('n', '<leader>es', ':tabe ~/.config/nvim/coc-settings.json<CR>', opts)
keymap('n', '<leader>et', ':tabe ~/.tmux.conf<CR>', opts)
keymap('n', '<leader>eg', ':tabe ~/.gitconfig<CR>', opts)
keymap('n', '<leader>ec', ':tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>', opts)
<<<<<<< HEAD
=======
keymap('n', '<leader>ev', ':tabe ~/.config/nvim/init.lua<CR>', { noremap = true, silent = true })
keymap('n', '<leader>es', ':tabe ~/.config/nvim/coc-settings.json<CR>', { noremap = true, silent = true })
keymap('n', '<leader>et', ':tabe ~/.tmux.conf<CR>', { noremap = true, silent = true })
keymap('n', '<leader>eg', ':tabe ~/.gitconfig<CR>', { noremap = true, silent = true })
keymap('n', '<leader>ec', ':tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>', { noremap = true, silent = true })
>>>>>>> 94c1409 (full migration)
=======
keymap('n', '<leader>ev', ':tabe ~/.config/nvim/init.lua<CR>', {noremap = true, silent = true})
keymap('n', '<leader>es', ':tabe ~/.config/nvim/coc-settings.json<CR>',
       {noremap = true, silent = true})
keymap('n', '<leader>et', ':tabe ~/.tmux.conf<CR>', {noremap = true, silent = true})
keymap('n', '<leader>eg', ':tabe ~/.gitconfig<CR>', {noremap = true, silent = true})
keymap('n', '<leader>ec', ':tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>',
       {noremap = true, silent = true})
>>>>>>> 178f39e (run format)
=======
>>>>>>> a812a09 (add saga)

-- *****************************************************************************
-- Git
-- *****************************************************************************
<<<<<<< HEAD
<<<<<<< HEAD
keymap('n', '<leader>c', "<ESC>/\v^[<=>]{7}( .*|$)<CR>", opts)
=======
keymap('n', '<leader>c', "<ESC>/\v^[<=>]{7}( .*|$)<CR>", {noremap = true, silent = true})
>>>>>>> 178f39e (run format)
=======
keymap('n', '<leader>c', "<ESC>/\v^[<=>]{7}( .*|$)<CR>", opts)
>>>>>>> a812a09 (add saga)
