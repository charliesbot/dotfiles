local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

return require "packer".startup(function(use)
  -- Local Packages
  -- use '~/dracula_pro'

  -- Themes
  use 'folke/tokyonight.nvim'
  use 'KeitaNakamura/neodark.vim'
  use 'morhetz/gruvbox'
  use { 'dracula/vim', as = 'dracula' }
  use 'ayu-theme/ayu-vim'
  use 'haishanh/night-owl.vim'

  use { 'mhinz/vim-startify' }
  use { 'scrooloose/nerdtree' }
  use { 'Xuyuanp/nerdtree-git-plugin' }

  use { 'nelstrom/vim-visual-star-search' }

  use { 'justinmk/vim-dirvish' }

  -- Helpers for UNIX
  use { 'tpope/vim-eunuch' }

  -- Visual tab {bottom}
  use { 'nvim-lualine/lualine.nvim' }

  -- Efficient moving
  use { 'justinmk/vim-sneak' }

  -- UI Widgets
  use { 'skywind3000/vim-quickui' }
  use { "junegunn/fzf.vim", requires = { "junegunn/fzf" } }
  use { "matze/vim-move" }
  use { "dominikduda/vim_current_word" }
  use { "tpope/vim-repeat" }
  use { "Konfekt/FastFold" }
  use { "metakirby5/codi.vim" }

  -- Language Support
  use { "nvim-treesitter/nvim-treesitter" }
  use { "nvim-treesitter/playground" }
  use { "p00f/nvim-ts-rainbow" }
  use { 'windwp/nvim-ts-autotag' }
  use { 'bfrg/vim-cpp-modern' }

  -- LSP
  use({
    "glepnir/lspsaga.nvim",
    branch = "main"
  })
  use { "jose-elias-alvarez/null-ls.nvim" }
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
    }
  }

  -- Flutter
  use { 'dart-lang/dart-vim-plugin' }
  use { 'thosakwe/vim-flutter' }

  -- Quoting/parenthesizing
  use { "machakann/vim-sandwich" }
  use { "jiangmiao/auto-pairs" }

  -- Comments
  -- use {'scrooloose/nerdcommenter'}
  use "b3nj5m1n/kommentary"

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
    -- tag = 'release' -- To use the latest release
  }

  -- Indent Lines
  use { 'lukas-reineke/indent-blankline.nvim' }

  -- Multiple Cursors
  use { 'terryma/vim-multiple-cursors' }

  -- Provides additional text objects
  use { 'wellle/targets.vim' }

  -- Highlight White Space
  use { 'ntpeters/vim-better-whitespace' }

end)
