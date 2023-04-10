local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "lewis6991/gitsigns.nvim",
  "echasnovski/mini.nvim",
  -- heads up: lualine blanks the start screen
  "nvim-lualine/lualine.nvim",
  "j-hui/fidget.nvim",
  "nvim-tree/nvim-web-devicons",
  "goolord/alpha-nvim",
  "tpope/vim-eunuch",
  "akinsho/flutter-tools.nvim",
  { "catppuccin/nvim",                 name = "catppuccin" },
  "ellisonleao/glow.nvim",
  "folke/trouble.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "HiPhish/nvim-ts-rainbow2",
  "chrisgrieser/nvim-spider",
  "chrisgrieser/nvim-various-textobjs",
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "VonHeikemen/lsp-zero.nvim",
    dependencies = {
      -- LSP Support
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Autocompletion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    }
  },
  {
    "nvim-tree/nvim-tree.lua",
    tag = "nightly",
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    }
  }
})
