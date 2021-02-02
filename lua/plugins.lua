vim.cmd 'packadd paq-nvim'         -- Load package
local paq = require'paq-nvim'.paq  -- Import module and bind `paq` function
paq {'savq/paq-nvim', opt=true}     -- Let Paq manage itself

-- My Packages

-- Themes
paq {'NLKNguyen/papercolor-theme'}
paq {'joshdick/onedark.vim'}
paq {'rakr/vim-one'}
paq {'KeitaNakamura/neodark.vim'}
paq {'trevordmiller/nova-vim'}
paq {'morhetz/gruvbox'}
paq {'tyrannicaltoucan/vim-quantum'}
paq {'dracula/vim', as='dracula'}
paq {'ayu-theme/ayu-vim'}
paq {'skielbasa/vim-material-monokai'}
paq {'haishanh/night-owl.vim'}
paq {'nightsense/snow'}
paq {'arcticicestudio/nord-vim'}
paq {'phanviet/vim-monokai-pro'}

paq {'mhinz/vim-startify'}
paq {'scrooloose/nerdtree'}
paq {'Xuyuanp/nerdtree-git-plugin'}

paq {'nelstrom/vim-visual-star-search'}

paq {'justinmk/vim-dirvish'}

-- Helpers for UNIX
paq {'tpope/vim-eunuch'}

-- Visual tab {bottom}
paq {'vim-airline/vim-airline'}
paq {'vim-airline/vim-airline-themes'}

-- Efficient moving
paq {'justinmk/vim-sneak'}

paq {'junegunn/fzf', hook = vim.fn['fzf#install']}
paq {'junegunn/fzf.vim'}
paq {'matze/vim-move'}
paq {'dominikduda/vim_current_word'}
paq {'tpope/vim-repeat'}
paq {'Konfekt/FastFold'}
paq {'metakirby5/codi.vim'}

-- Language Support
paq {'nvim-treesitter/nvim-treesitter'}
paq {'nvim-treesitter/playground'}

-- Quoting/parenthesizing
paq {'machakann/vim-sandwich'}
paq {'jiangmiao/auto-pairs'}

-- Comments
paq {'scrooloose/nerdcommenter'}

-- Git
paq {'airblade/vim-gitgutter'}

-- Multiple Cursors
paq {'terryma/vim-multiple-cursors'}

-- Provides additional text objects
paq {'wellle/targets.vim'}

-- Term
paq {'voldikss/vim-floaterm'}

-- Highlight White Space
paq {'ntpeters/vim-better-whitespace'}

paq {'neoclide/coc.nvim', branch='release'}
