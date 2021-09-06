-- Nerd Commenter
vim.cmd('let NERDSpaceDelims = 1')

-- Vim Sneak
vim.g['sneak#s_next'] = 1
vim.g['sneak#label'] = 1

-- NerdTree
vim.g.NERDTreeHijackNetrw = 0
vim.g.nerdtree_tabs_focus_on_files = 1
vim.cmd('let NERDTreeShowHidden=1')
vim.cmd("let NERDTreeIgnore=['\\.DS_Store', '\\~$', '\\.swp']")

-- Vim Move
-- <C-k>   Move current line/selections up
-- <C-j>   Move current line/selections down
vim.g.move_key_modifier = 'C'

-- Git Signs
require('gitsigns').setup()

-- Lualine
require'lualine'.setup {
    options = {theme = 'tokyonight'},
    sections = {lualine_a = {{'mode', lower = false}}, lualine_b = {}}
}
