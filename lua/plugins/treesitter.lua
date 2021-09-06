require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    indent = {enable = true},
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false -- Whether the query persists across vim sessions
    },
    rainbow = {
        enable = true,
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil -- Do not enable for files with more than n lines, int
    },
    autotag = {enable = true},
    context_commentstring = {
        enable = true,
        config = {javascriptreact = {style_element = '{/*%s*/}'}}
    }
}
