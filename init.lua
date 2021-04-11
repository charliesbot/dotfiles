require('plugins')
require('settings')

-- packages config

--require('plugins.treesitter')
require('plugins.smallConfigs')
require('plugins.codi')
require('plugins.fzf')
require('plugins.quickUI')
require('plugins.startify')
require('plugins.multiCursor')
require('plugins.indentLines')

-- LSP
require('lsp')
require('lsp.setup-ls')

require('plugins.compe')
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
  monokaiPrp = 'monokai_pro',
  nightOwl = 'night-owl',
  nord = 'nord',
  nova = 'nova',
  one = 'one',
  oneDark = 'onedark',
  oneHalfDark='onehalfdark',
  paperColor = 'PaperColor',
  quantum = 'quantum',
  snow = 'snow',
}

vim.cmd(string.format('colorscheme ' .. colorSchemes.draculaPro))
