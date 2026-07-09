-- Modern AI Neovim, rebuilt from scratch.
-- init.lua is a thin loader: leader first, then each config module runs in order.
-- See modern-ai-nvim.md for the full plan.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'
-- Choose the active colorscheme after plugins (themes) have loaded.
require 'config.theme'
require 'config.statusline'
