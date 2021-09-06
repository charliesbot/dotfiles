-- Vim Sneak
vim.g['sneak#s_next'] = 1
vim.g['sneak#label'] = 1

-- NerdTree
-- vim.cmd("let NERDTreeIgnore=['\\.DS_Store', '\\~$', '\\.swp']") ]]
local chadtree_settings = {
    ["theme.text_colour_set"] = "env",
    ['theme.icon_glyph_set'] = 'ascii',
    ["options.show_hidden"] = true,
    ["ignore.name_exact"] = {".DS_Store", "thumbs.db"}
}
vim.api.nvim_set_var("chadtree_settings", chadtree_settings)

-- Vim Move
-- <C-k>   Move current line/selections up
-- <C-j>   Move current line/selections down
vim.g.move_key_modifier = 'C'

-- Git Signs
require('gitsigns').setup()

-- Lualine
require'lualine'.setup {
    options = {theme = 'tokyonight'},
    sections = {
        lualine_a = {{'mode', lower = false}},
        lualine_b = {'filename'},
        lualine_c = {
            {
                'diagnostics',
                sources = {"nvim_lsp"},
                symbols = {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'}
            }
        },
        lualine_x = {'encoding', 'filetype'}
    }
}
