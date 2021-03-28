local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

return require "packer".startup(
  function(use)
    -- My Packages

    -- Themes
    use {'NLKNguyen/papercolor-theme'}
    use {'joshdick/onedark.vim'}
    use {'rakr/vim-one'}
    use {'KeitaNakamura/neodark.vim'}
    use {'trevordmiller/nova-vim'}
    use {'morhetz/gruvbox'}
    use {'tyrannicaltoucan/vim-quantum'}
    use {'dracula/vim', as='dracula'}
    use {'ayu-theme/ayu-vim'}
    use {'skielbasa/vim-material-monokai'}
    use {'haishanh/night-owl.vim'}
    use {'nightsense/snow'}
    use {'arcticicestudio/nord-vim'}
    use {'phanviet/vim-monokai-pro'}
    use '~/dracula_pro'

    use {'mhinz/vim-startify'}
    use {'scrooloose/nerdtree'}
    use {'Xuyuanp/nerdtree-git-plugin'}

    use {'nelstrom/vim-visual-star-search'}

    use {'justinmk/vim-dirvish'}

    -- Helpers for UNIX
    use {'tpope/vim-eunuch'}

    -- Visual tab {bottom}
    use {'vim-airline/vim-airline'}
    use {'vim-airline/vim-airline-themes'}

    -- Efficient moving
    use {'justinmk/vim-sneak'}

    -- UI Widgets
    use {'skywind3000/vim-quickui'}
    use {
      "junegunn/fzf.vim",
      requires = {"junegunn/fzf"}
    }
    use {'matze/vim-move'}
    use {'dominikduda/vim_current_word'}
    use {'tpope/vim-repeat'}
    use {'Konfekt/FastFold'}
    use {'metakirby5/codi.vim'}

    -- Language Support
    use {'sheerun/vim-polyglot'}

    -- Quoting/parenthesizing
    use {'machakann/vim-sandwich'}
    use {'jiangmiao/auto-pairs'}

    -- Comments
    use {'scrooloose/nerdcommenter'}

    -- Git
    use {
      'lewis6991/gitsigns.nvim',
      requires = {
        'nvim-lua/plenary.nvim'
      }
    }

    -- Multiple Cursors
    use {'terryma/vim-multiple-cursors'}

    -- Provides additional text objects
    use {'wellle/targets.vim'}

    -- Term
    use {'voldikss/vim-floaterm'}

    -- Highlight White Space
    use {'ntpeters/vim-better-whitespace'}

    -- LSP
    use {'neoclide/coc.nvim', branch='release'}
  end
)


-- Neovim 0.5
-- use {'neovim/nvim-lspconfig'}
-- use {'hrsh7th/nvim-compe'}
-- use {'nvim-treesitter/nvim-treesitter'}
-- use {'nvim-treesitter/playground'}
