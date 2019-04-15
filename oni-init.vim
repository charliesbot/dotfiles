call plug#begin()

Plug 'machakann/vim-sandwich'
Plug 'matze/vim-move'
Plug 'dominikduda/vim_current_word'
Plug 'tpope/vim-repeat'
Plug 'kassio/neoterm'

" Tree
Plug 'justinmk/vim-dirvish'
Plug 'mhinz/vim-startify'

" Helpers for UNIX
Plug 'tpope/vim-eunuch'
Plug 'ervandew/supertab'

Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

" Colorscheme
Plug 'nightsense/snow'

call plug#end()

let mapleader=' '
let g:move_key_modifier = 'C'

" Have the indent commands re-highlight the last visual selection to make
" multiple indentations easier
vnoremap > >gv
vnoremap < <gv
inoremap jj <ESC>

set background=dark
