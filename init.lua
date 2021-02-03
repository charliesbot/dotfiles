require('plugins')
require('settings')

-- packages config

require('plugins.smallConfigs')
require('plugins.codi')
require('plugins.fzf')
require('plugins.quickUI')
require('plugins.startify')
require('plugins.treesitter')
require('plugins.multiCursor')

-- end packages config

require('keybindings')
require('colors')
require('customFunctions')

local colorSchemes = {
  gruvbox = 'gruvbox',
  paperColor = 'PaperColor',
  one = 'one',
  nova = 'nova',
  oneDark = 'onedark',
  cobalt = 'cobalt2',
  quantum = 'quantum',
  ayu = 'ayu',
  oneHalfDark='onehalfdark',
  materialMonokai = 'material-monokai',
  dracula = 'dracula',
  gruvboxMaterial = 'gruvbox-material',
  nord = 'nord',
  nightOwl = 'night-owl',
  snow = 'snow',
  monoKaiProp = 'monokai_pro'
}

vim.cmd(string.format('colorscheme ' .. colorSchemes.dracula))
