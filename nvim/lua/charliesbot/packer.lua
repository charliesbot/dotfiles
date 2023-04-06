-- Only required if you have packer configured as `opt`
vim.cmd.packadd("packer.nvim")

return require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")
  use("lewis6991/gitsigns.nvim")
  use "echasnovski/mini.nvim"
  -- heads up: lualine blanks the start screen
  use("nvim-lualine/lualine.nvim")
  use("j-hui/fidget.nvim")
  use("nvim-tree/nvim-web-devicons")
  use("goolord/alpha-nvim")
  use("tpope/vim-eunuch")
  use("akinsho/flutter-tools.nvim")
  use({ "catppuccin/nvim", as = "catpuccin" })
  use("ellisonleao/glow.nvim")
  use("folke/trouble.nvim")
  use("lukas-reineke/indent-blankline.nvim")
  use("HiPhish/nvim-ts-rainbow2")
  use("chrisgrieser/nvim-spider")
  use("chrisgrieser/nvim-various-textobjs")
  use({
    "utilyre/barbecue.nvim",
    tag = "*",
    requires = {
      "SmiteshP/nvim-navic",
    },
  })
  use({
    "nvim-telescope/telescope.nvim",
    tag = "0.1.0",
    requires = { { "nvim-lua/plenary.nvim" } },
  })
  use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
  use({
    "VonHeikemen/lsp-zero.nvim",
    requires = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },
      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },
    },
  })
  use({
    "nvim-tree/nvim-tree.lua",
    tag = "nightly",
  })
  use({
    "jose-elias-alvarez/null-ls.nvim",
    "jay-babu/mason-null-ls.nvim",
  })
end)
