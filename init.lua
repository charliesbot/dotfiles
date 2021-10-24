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

-- LSP
require('lsp')
require('lsp.setup')

require('plugins.cmp')
require('plugins.lspConfig')

-- end packages config

require('keybindings')
require('colors')
require('customFunctions')

local colorSchemes = {
    ayu = 'ayu',
    cobalt = 'cobalt2',
    dracula = 'dracula',
    draculaPro = 'dracula_pro',
    gruvbox = 'gruvbox',
    gruvboxMaterial = 'gruvbox-material',
    materialMonokai = 'material-monokai',
    monokaiPro = 'monokai_pro',
    nightOwl = 'night-owl',
    nord = 'nord',
    nova = 'nova',
    one = 'one',
    oneHalfDark = 'onehalfdark',
    paperColor = 'PaperColor',
    quantum = 'quantum',
    tokyoNight = 'tokyonight'
}

vim.cmd(string.format('colorscheme ' .. colorSchemes.tokyoNight))
