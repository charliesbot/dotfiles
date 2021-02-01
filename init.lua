require('settings')
require('plugins')
require('pluginsConfig')
require('keybindings')
require('colors')
require('customFunctions')

-- Map leader to space

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

vim.cmd(string.format('colorscheme %s', colorSchemes.dracula))
