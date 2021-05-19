local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

return require"packer".startup(function(use)
    -- Local Packages
    use '~/dracula_pro'

    -- Themes
    use 'folke/tokyonight.nvim'
    use {'NLKNguyen/papercolor-theme'}
    use {'joshdick/onedark.vim'}
    use {'rakr/vim-one'}
    use {'KeitaNakamura/neodark.vim'}
    use {'trevordmiller/nova-vim'}
    use {'morhetz/gruvbox'}
    use {'tyrannicaltoucan/vim-quantum'}
    use {'dracula/vim', as = 'dracula'}
    use {'ayu-theme/ayu-vim'}
    use {'skielbasa/vim-material-monokai'}
    use {'haishanh/night-owl.vim'}
    use {'nightsense/snow'}
    use {'arcticicestudio/nord-vim'}
    use {'phanviet/vim-monokai-pro'}

    use {'mhinz/vim-startify'}
    use {'scrooloose/nerdtree'}
    use {'Xuyuanp/nerdtree-git-plugin'}

    use {'nelstrom/vim-visual-star-search'}

    use {'justinmk/vim-dirvish'}

    -- Helpers for UNIX
    use {'tpope/vim-eunuch'}

    -- Visual tab {bottom}
    -- use {'vim-airline/vim-airline'}
    -- use {'vim-airline/vim-airline-themes'}

    -- Efficient moving
    use {'justinmk/vim-sneak'}

    -- UI Widgets
    use {'skywind3000/vim-quickui'}
    use {"junegunn/fzf.vim", requires = {"junegunn/fzf"}}
    use {'matze/vim-move'}
    use {'dominikduda/vim_current_word'}
    use {'tpope/vim-repeat'}
    use {'Konfekt/FastFold'}
    use {'metakirby5/codi.vim'}

    -- Language Support
    use {'nvim-treesitter/nvim-treesitter'}
    use {'nvim-treesitter/playground'}

    -- LSP
    use {'neoclide/coc.nvim', branch = 'release'}

    -- Flutter
    use {'dart-lang/dart-vim-plugin'}
    use {'thosakwe/vim-flutter'}

    -- Quoting/parenthesizing
    use {'machakann/vim-sandwich'}
    use {'jiangmiao/auto-pairs'}

    -- Comments
    use {'scrooloose/nerdcommenter'}

    -- Git
    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}

    -- Indent Lines
    use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'}

    -- Indent Lines
    use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'}

    -- Multiple Cursors
    use {'terryma/vim-multiple-cursors'}

    -- Provides additional text objects
    use {'wellle/targets.vim'}

    -- Highlight White Space
    use {'ntpeters/vim-better-whitespace'}
end)
