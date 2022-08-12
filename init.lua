require('plugins')
require('settings')

-- packages config

require('plugins.treesitter')
require('plugins.smallConfigs')
require('plugins.codi')
require('plugins.fzf')
require('plugins.quickUI')
require('plugins.startify')
require('plugins.multiCursor')
require('plugins.indentLines')
require('plugins.null_ls')

-- LSP
require('lsp')

-- end packages config

require('keybindings')
require('colors')
require('customFunctions')

local colorSchemes = {
    ayu = 'ayu',
    dracula = 'dracula',
    draculaPro = 'dracula_pro',
    gruvbox = 'gruvbox',
    gruvboxMaterial = 'gruvbox-material',
    nightOwl = 'night-owl',
    nova = 'nova',
    tokyoNight = 'tokyonight'
}

vim.cmd(string.format('colorscheme ' .. colorSchemes.dracula))
