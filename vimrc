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
Plug 'dracula/vim'
Plug 'ayu-theme/ayu-vim'
Plug 'skielbasa/vim-material-monokai'

Plug 'mhinz/vim-startify'

" Search
Plug 'nelstrom/vim-visual-star-search'

" Tree
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'justinmk/vim-dirvish'

" Helpers for UNIX
Plug 'tpope/vim-eunuch'

" Visual tab {bottom}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Efficient moving
Plug 'justinmk/vim-sneak'

" General
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'yuki-ycino/fzf-preview.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'matze/vim-move'
Plug 'dominikduda/vim_current_word'
Plug 'tpope/vim-repeat'
Plug 'Konfekt/FastFold'

" Neoterm
Plug 'kassio/neoterm'

" Language Support
Plug 'sheerun/vim-polyglot'
Plug 'ElmCast/elm-vim', { 'for': ['elm'] }
Plug 'mxw/vim-jsx', { 'for': ['javascript.jsx'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'styled-components/vim-styled-components', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'jparise/vim-graphql'
Plug 'gabrielelana/vim-markdown'
Plug 'reasonml-editor/vim-reason-plus', { 'for': 'reason' }

" Autocomplete
Plug 'roxma/nvim-completion-manager'
Plug 'autozimu/LanguageClient-neovim', {
      \ 'branch': 'next',
      \ 'do': 'bash install.sh',
      \ }

" Syntax
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Language Formatter
Plug 'sbdchd/neoformat'
Plug 'editorconfig/editorconfig-vim'

" Lintern
Plug 'w0rp/ale'

" Quoting/parenthesizing
Plug 'machakann/vim-sandwich'
Plug 'jiangmiao/auto-pairs'

" Matcher
Plug 'andymass/vim-matchup'

" Comments
Plug 'scrooloose/nerdcommenter'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jreybert/vimagit'

" Multiple Cursors
Plug 'terryma/vim-multiple-cursors'

" Provides additional text objects
Plug 'wellle/targets.vim'

" Highlight White Space
Plug 'ntpeters/vim-better-whitespace'

call plug#end()

"*****************************************************************************
"" Settings
"*****************************************************************************
set termguicolors                     " enable true colors
set hidden
set nopaste

" Indentation
set expandtab
set shiftwidth=2
set softtabstop=2

set splitright                        " vsplit at right side"
set cursorline
set number
set wildmode=longest:list,full        " command line completion
set whichwrap=b,s,h,l,<,>,[,]         " backspace and cursor keys wrap too
set showmatch                         " highlight matching parenthesis
set updatetime=100                    " Update file each 100ms

" searching
set ignorecase                        " set case insensitive searching
set smartcase                         " case sensitive searching when not all lowercase
set inccommand=split                  " Live replacing using %s/text/newText

set mouse=a                           " Set mouse support

" background processes
set clipboard=unnamed                 " use native clipboard
set lazyredraw                        " no unneeded redraws
set nobackup                          " don't save backups
set noerrorbells                      " no error bells please
set noswapfile                        " no swapfiles

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

set shortmess+=c

set completeopt-=preview " hide preview function window"


"*****************************************************************************
"" Visual Settings
"*****************************************************************************

" Map leader to space
let mapleader=' '

let g:onedark_terminal_italics = 1
let g:one_allow_italics = 1
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
let g:gruvbox_italic = 1
let g:neodark#solid_vertsplit = 1
let g:materialmonokai_italic = 1
let ayucolor="mirage"
set background=dark
set t_ut=

"colorscheme gruvbox
"colorscheme PaperColor
"colorscheme one
"colorscheme neodark
"colorscheme nova
"colorscheme onedark
"colorscheme cobalt2
"colorscheme quantum
"colorscheme ayu
colorscheme material-monokai
"colorscheme dracula

hi Comment   cterm=italic gui=italic
hi htmlArg   cterm=italic gui=italic
hi Type      cterm=italic gui=italic
hi xmlAttrib cterm=italic gui=italic
hi jsxAttrib cterm=italic gui=italic

"*****************************************************************************
"" Mappings
"*****************************************************************************
map <C-b> :NERDTreeToggle<CR>

" search and replace
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gp :Gpull<cr>
nnoremap <leader>gP :Gpush<cr>

nnoremap <C-p> :GitFiles<CR>
nnoremap <C-P> :FZF<CR>
nnoremap <leader>ff :Files<cr>
nnoremap <leader>fb :Buffers<cr>
nnoremap <leader>fg :GFiles<cr>
nnoremap <C-f> :Ag<space>

" search current word under cursor
nnoremap <silent> <Leader>ag :Ag <C-R><C-W><CR>

" replace text under cursor
nnoremap <silent><Leader>r :%s/<C-R><C-W>/

nnoremap zC zM
nnoremap zO zR

nnoremap zz <C-w>|

" LSP
nnoremap <silent> gh :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>

" Have the indent commands re-highlight the last visual selection to make
" multiple indentations easier
vnoremap > >gv
vnoremap < <gv

inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

" Clear search highlight
nnoremap <esc> :noh<return><esc>

noremap <Leader>f :Neoformat<CR>

" ALE
nnoremap <Leader>d :ALEDetail<CR>
nnoremap <Leader>n :ALENextWrap<CR>
" Toggle the autoopening of lists
nnoremap <silent><Leader>q :call ToggleAleAutoList()<CR>

nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F

nnoremap <Leader>jj :Ttoggle<CR>
tnoremap jj <C-\><C-n> :Ttoggle<CR>

" Create new file from current buffer path
function! s:CreateNewFile(fileName)
  execute "vnew %:h/" . a:fileName
endfunction
command! -nargs=1 Nfile call s:CreateNewFile(<f-args>)

nnoremap <Leader>V :vsplit<CR>

" find git merge conflict markers
noremap <silent> <leader>c <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" Quickly edit and source config files
noremap <leader>ev :tabe ~/.config/nvim/init.vim<CR>
noremap <leader>s :source ~/.config/nvim/init.vim<CR>
noremap <leader>et :tabe ~/.tmux.conf<CR>
noremap <leader>eg :tabe ~/.gitconfig<CR>
noremap <leader>ec :tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>

"*****************************************************************************
"" Configs
"*****************************************************************************

" Neoterm
let g:neoterm_window = '10new'
let g:neoterm_autoinsert = 1

" Neoformat
let g:neoformat_basic_format_align = 1
let g:neoformat_basic_format_retab = 1
let g:neoformat_basic_format_trim = 1

" Vim multiple cursors
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-m>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" Vim-Sneak
let g:sneak#s_next = 1

" Magit
let g:magit_show_magit_mapping='<leader>m'

" JSX syntax in JS files
let g:jsx_ext_required = 0
let g:javascript_plugin_flow = 1

" Git gutter
let g:gitgutter_override_sign_column_highlight = 0
highlight clear SignColumn

" NerdTree
let g:NERDTreeHijackNetrw = 0
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.DS_Store', '\~$', '\.swp']
let g:nerdtree_tabs_focus_on_files = 1

" Vim Move
" <C-k>   Move current line/selections up
" <C-j>   Move current line/selections down
let g:move_key_modifier = 'C'

" Supertab
let g:SuperTabContextDefaultCompletionType = '<c-n>'
let g:SuperTabDefaultCompletionType = '<C-n>'

" Elm
let g:elm_detailed_complete = 1
let g:elm_format_autosave = 1

" Startify
let g:startify_change_to_vcs_root = 1
let g:startify_list_order = [
      \ ['   These are my sessions:'],
      \ 'sessions',
      \ ['   Recently used files in the current directory:'],
      \ 'dir',
      \ ['   Recently used files'],
      \ 'files',
      \ ['   These are my bookmarks:'],
      \ 'bookmarks',
      \ ['   These are my commands:'],
      \ 'commands',
      \ ]

" Ale
let g:ale_sign_column_always = 1

" NCM
let g:cm_refresh_default_min_word_len = [[1, 2]]

" Airline
let g:airline_section_z="%l/%c"
let g:airline_theme='neodark'
let g:airline#extensions#ale#enabled = 1

" Disable git changes
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#branch#enabled = 0 " Disable branch

" Polyglot
let g:polyglot_disabled = ['elm', 'javascript', 'jsx', 'css', 'markdown']

" LanguageClient
let g:LanguageClient_serverCommands = {
      \ 'javascript': ['flow-language-server', '--stdio'],
      \ 'javascript.jsx': ['flow-language-server', '--stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ 'reason': ['ocaml-language-server'],
      \ 'ocaml': ['ocaml-language-server'],
      \ 'python': ['pyls'],
      \ }

let g:LanguageClient_autoStart = 1

let g:ale_linters = {'jsx': ['stylelint', 'eslint']}
let g:ale_linter_aliases = {'jsx': 'css'}

"FZF + ripgrep
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

" Toggles shows or hides the nonempty lists
" and turns on Ales auto open
fun! ToggleAleAutoList()
  let l:winnr = winnr()
  if g:ale_open_list
    let g:ale_open_list = 0
    cclose
    lclose
  else
    if len(getqflist()) != 0
      copen
      stopinsert
    endif
    if len(getloclist(0)) != 0
      lopen
    endif
    let g:ale_open_list = 1
  endif
  if l:winnr !=# winnr()
    wincmd p
  endif
endfun

" ----------------------------
" ---- File type settings ----
" ----------------------------
autocmd BufNewFile,BufRead *.*rc set filetype=javascript
