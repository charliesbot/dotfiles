require('plugins')
require('settings')

-- packages config

require('plugins.smallConfigs')
require('plugins.codi')
require('plugins.fzf')
require('plugins.quickUI')
require('plugins.startify')
require('plugins.multiCursor')
-- Neovim 0.5
-- require('plugins.lsp_config')
-- require('plugins.compe')
-- require('plugins.treesitter')

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
