local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

return require"packer".startup(function(use)
    -- Local Packages
    -- use '~/dracula_pro'

    -- Themes
    use 'folke/tokyonight.nvim'
    use 'NLKNguyen/papercolor-theme'
    use 'rakr/vim-one'
    use 'KeitaNakamura/neodark.vim'
    use 'trevordmiller/nova-vim'
    use 'morhetz/gruvbox'
    use 'tyrannicaltoucan/vim-quantum'
    use {'dracula/vim', as = 'dracula'}
    use 'ayu-theme/ayu-vim'
    use 'skielbasa/vim-material-monokai'
    use 'haishanh/night-owl.vim'
    use 'arcticicestudio/nord-vim'
    use 'phanviet/vim-monokai-pro'

    use {'mhinz/vim-startify'}
    -- use {'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps'}
    use {'scrooloose/nerdtree'}
    use {'Xuyuanp/nerdtree-git-plugin'}

    use {'nelstrom/vim-visual-star-search'}

    use {'justinmk/vim-dirvish'}

    -- Helpers for UNIX
    use {'tpope/vim-eunuch'}

    -- Visual tab {bottom}
    use {'nvim-lualine/lualine.nvim'}

    -- Efficient moving
    use {'justinmk/vim-sneak'}

    -- UI Widgets
    use {'skywind3000/vim-quickui'}
    use {"junegunn/fzf.vim", requires = {"junegunn/fzf"}}
    use {"matze/vim-move"}
    use {"dominikduda/vim_current_word"}
    use {"tpope/vim-repeat"}
    use {"Konfekt/FastFold"}
    use {"metakirby5/codi.vim"}

    -- Language Support
    use {"nvim-treesitter/nvim-treesitter"}
    use {"nvim-treesitter/playground"}
    use {"p00f/nvim-ts-rainbow"}
    use {'windwp/nvim-ts-autotag'}
    use 'bfrg/vim-cpp-modern'

    -- LSP
    use "hrsh7th/nvim-cmp" -- Autocompletion plugin
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-vsnip"
    use "hrsh7th/vim-vsnip"
    use "mhartington/formatter.nvim"
    use "neovim/nvim-lspconfig"
    use "glepnir/lspsaga.nvim"
    use "williamboman/nvim-lsp-installer"

    -- Flutter
    use {'dart-lang/dart-vim-plugin'}
    use {'thosakwe/vim-flutter'}

    -- Quoting/parenthesizing
    use {"machakann/vim-sandwich"}
    use {"jiangmiao/auto-pairs"}

    -- Comments
    -- use {'scrooloose/nerdcommenter'}
    use "b3nj5m1n/kommentary"

    -- Git
    use {
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'}
        -- tag = 'release' -- To use the latest release
    }

    -- Indent Lines
    use {'lukas-reineke/indent-blankline.nvim'}

    -- Multiple Cursors
    use {'terryma/vim-multiple-cursors'}

    -- Provides additional text objects
    use {'wellle/targets.vim'}

    -- Highlight White Space
    use {'ntpeters/vim-better-whitespace'}

end)
