"*****************************************************************************
"" Plugins
"*****************************************************************************
call plug#begin('~/.vim/plugged')

" Theme
Plug 'NLKNguyen/papercolor-theme'
Plug 'joshdick/onedark.vim'
Plug 'rakr/vim-one'
Plug 'KeitaNakamura/neodark.vim'
Plug 'pwntester/cobalt2.vim'
Plug 'trevordmiller/nova-vim'
Plug 'morhetz/gruvbox'
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'ayu-theme/ayu-vim'
Plug 'skielbasa/vim-material-monokai'
Plug 'mhartington/oceanic-next'
Plug 'haishanh/night-owl.vim'
Plug 'nightsense/snow'
Plug 'arcticicestudio/nord-vim'
Plug 'phanviet/vim-monokai-pro'
Plug 'Rigellute/shades-of-purple.vim'
Plug 'sonph/onehalf', {'rtp': 'vim/'}

Plug 'mhinz/vim-startify'

" Search
Plug 'nelstrom/vim-visual-star-search'

" Tree
Plug 'justinmk/vim-dirvish'

" Helpers for UNIX
Plug 'tpope/vim-eunuch'

" Visual tab {bottom}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Efficient moving
Plug 'justinmk/vim-sneak'

" General
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
" Plug 'ryanoasis/vim-devicons'
Plug 'matze/vim-move'
Plug 'dominikduda/vim_current_word'
Plug 'tpope/vim-repeat'
Plug 'Konfekt/FastFold'
Plug 'metakirby5/codi.vim'

" Language Support
Plug 'hail2u/vim-css3-syntax'
Plug 'sheerun/vim-polyglot'
" Plug 'HerringtonDarkholme/yats.vim', { 'for': ['typescript', 'typescript.tsx'] }
Plug 'jxnblk/vim-mdx-js'
Plug 'reasonml-editor/vim-reason-plus', { 'do': 'npm i -g ocaml-language-server' }
Plug 'jparise/vim-graphql'
Plug 'gabrielelana/vim-markdown', { 'for': ['markdown'] }
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'

" Language Formatter
Plug 'sbdchd/neoformat'

" Quoting/parenthesizing
Plug 'machakann/vim-sandwich'
Plug 'jiangmiao/auto-pairs'

" Comments
Plug 'scrooloose/nerdcommenter'

" Git
Plug 'airblade/vim-gitgutter'

" Multiple Cursors
Plug 'terryma/vim-multiple-cursors'

" Provides additional text objects
Plug 'wellle/targets.vim'

" Highlight White Space
Plug 'ntpeters/vim-better-whitespace'

Plug 'neoclide/coc.nvim', {'do': './install.sh nightly'}
Plug 'liuchengxu/vista.vim'
" Plug 'ervandew/supertab'

call plug#end()

