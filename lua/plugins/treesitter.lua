require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    indent = {enable = true},
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
