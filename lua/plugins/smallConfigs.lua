-- Nerd Commenter
vim.cmd('let NERDSpaceDelims = 1')

-- Vim Sneak
vim.g['sneak#s_next'] = 1
vim.g['sneak#label'] = 1

-- Vim Gutter
vim.g.gitgutter_override_sign_column_highlight = 0

-- NerdTree
vim.g.NERDTreeHijackNetrw = 0
vim.g.nerdtree_tabs_focus_on_files = 1
vim.cmd('let NERDTreeShowHidden=1')
vim.cmd("let NERDTreeIgnore=['\\.DS_Store', '\\~$', '\\.swp']")

-- Vim Move
-- <C-k>   Move current line/selections up
-- <C-j>   Move current line/selections down
vim.g.move_key_modifier = 'C'

-- Airline
vim.g.airline_section_z = "%l/%c"
-- Disable git changes
-- vim.g['airline#extensions#hunks#enabled'] = 0
-- vim.g['airline#extensions#branch#enabled'] = 0 -- Disable branch

-- Git Signs
require('gitsigns').setup()
