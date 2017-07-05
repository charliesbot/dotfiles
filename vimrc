"*****************************************************************************
"" Plugins
"*****************************************************************************
call plug#begin('~/.vim/plugged')

" Theme
Plug 'mhartington/oceanic-next'
Plug 'NLKNguyen/papercolor-theme'
Plug 'joshdick/onedark.vim'
Plug 'rakr/vim-one'
Plug 'KeitaNakamura/neodark.vim'
Plug 'pwntester/cobalt2.vim'
Plug 'trevordmiller/nova-vim'

Plug 'mhinz/vim-startify'

Plug 'nelstrom/vim-visual-star-search'

" Tree
Plug 'scrooloose/nerdtree'

" Denite
"Plug 'Shougo/denite.nvim'

" Visual tab {bottom}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Efficient moving
Plug 'justinmk/vim-sneak'

" General
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'alvan/vim-closetag'
Plug 'matze/vim-move'
Plug 't9md/vim-choosewin'
Plug 'dominikduda/vim_current_word'
Plug 'tpope/vim-repeat'

" Neoterm
Plug 'kassio/neoterm'

" Language Support
Plug 'sheerun/vim-polyglot'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'ElmCast/elm-vim'
Plug 'pangloss/vim-javascript'
"Plug 'othree/yajs.vim'
"Plug 'othree/es.next.syntax.vim'
"Plug 'flowtype/vim-flow', { 'for': 'javascript.jsx' }

" Autocomplete
" Deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'pbogut/deoplete-elm', { 'for': ['elm'] }
Plug 'wokalski/autocomplete-flow'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'

" Syntax
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Valloric/MatchTagAlways'

" Language Formatter
Plug 'sbdchd/neoformat'
Plug 'editorconfig/editorconfig-vim'

" Lintern
Plug 'w0rp/ale'

" Quoting/parenthesizing
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

" Comments
Plug 'scrooloose/nerdcommenter'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jreybert/vimagit'

" Multiple Cursors
Plug 'terryma/vim-multiple-cursors'

" Emmet
Plug 'mattn/emmet-vim'

"Easymotion
Plug 'easymotion/vim-easymotion'

" Provides additional text objects
Plug 'wellle/targets.vim'

" Highlight White Space
Plug 'ntpeters/vim-better-whitespace'

call plug#end()

"*****************************************************************************
"" Settings
"*****************************************************************************
set termguicolors                     " enable true colors

" Indentation
set expandtab
set shiftwidth=2
set softtabstop=2

set splitright                        " vsplit at right side"
set cursorline
set number
set relativenumber
set wildmode=longest:list,full        " command line completion
set whichwrap=b,s,h,l,<,>,[,]         " backspace and cursor keys wrap too
set showmatch                         " highlight matching parenthesis
set updatetime=250                    " Update file each 250ms

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


"*****************************************************************************
"" Visual Settings
"*****************************************************************************

" Map leader to space
let mapleader=' '

let g:onedark_terminal_italics = 1
let g:one_allow_italics = 1
set background=dark
"colorscheme PaperColor
"colorscheme one
colorscheme neodark
"colorscheme nova
"colorscheme onedark
"colorscheme cobalt2

hi htmlArg gui=italic
hi Comment gui=italic
hi Type    gui=italic
hi htmlArg cterm=italic
hi Comment cterm=italic
hi Type    cterm=italic

"*****************************************************************************
"" Mappings
"*****************************************************************************
map <C-b> :NERDTreeToggle<CR>

" Resource vimrc
nnoremap <leader>s :so %<CR>

" search and replace
nmap <leader>gs :Gstatus<cr>
nmap <leader>gc :Gcommit<cr>
nmap <leader>gd :Gdiff<cr>
nmap <leader>gp :Gpull<cr>
nmap <leader>gP :Gpush<cr>

nnoremap <C-p> :GitFiles<CR>
nnoremap <C-P> :FZF<CR>
nnoremap <C-f> :Ag 

" Have the indent commands re-highlight the last visual selection to make
" multiple indentations easier
vnoremap > >gv
vnoremap < <gv

inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

" Clear search highlight
nnoremap <esc> :noh<return><esc>

noremap <Leader>f :Neoformat<CR>

nnoremap <Leader>d :ALEDetail<CR>
nnoremap <Leader>n :ALENextWrap<CR>

nmap <Leader>\ <Plug>(choosewin)

nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F

nnoremap <Leader>jj :Ttoggle<CR>
tnoremap jj <C-\><C-n> :Ttoggle<CR>

" find git merge conflict markers
nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" Quickly edit and source config files
noremap <leader>ev :tabe ~/.config/nvim/init.vim<CR>
noremap <leader>sv :source ~/.config/nvim/init.vim<CR>
noremap <leader>et :tabe ~/.tmux.conf<CR>
noremap <leader>eg :tabe ~/.gitconfig<CR>

"*****************************************************************************
"" Configs
"*****************************************************************************

" Neoterm
let g:neoterm_window = '10new'
let g:neoterm_autoinsert = 1

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

" Close Tag
let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.js,*.jsx"

" Javascript libs syntax
let g:used_javascript_libs = 'react, ramda'

set completeopt-=preview " hide preview function window"

" NerdTree
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.DS_Store', '\~$', '\.swp']
let g:nerdtree_tabs_focus_on_files = 1

" indentLine
let g:indentLine_enabled = 1
let g:indentLine_faster = 1

" Vim Move
" <C-k>   Move current line/selections up
" <C-j>   Move current line/selections down
let g:move_key_modifier = 'C'

" MatchTagAlways
let g:mta_filetypes = { 'javascript.jsx': 1, 'html' : 1,  'xhtml' : 1, 'xml' : 1, 'jinja' : 1, }

" Supertab
let g:SuperTabContextDefaultCompletionType = '<c-n>'
let g:SuperTabDefaultCompletionType = '<C-n>'

" Elm
let g:elm_detailed_complete = 1
let g:elm_format_autosave = 1

" Choosewin
let g:choosewin_overlay_enable = 1
let g:choosewin_label = '123456789'
let g:choosewin_tablabel = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

" Startify
let g:startify_change_to_vcs_root = 1
let g:startify_list_order = [
            \ ['   Recently used files in the current directory:'],
            \ 'dir',
            \ ['   Recently used files'],
            \ 'files',
            \ ['   These are my sessions:'],
            \ 'sessions',
            \ ['   These are my bookmarks:'],
            \ 'bookmarks',
            \ ['   These are my commands:'],
            \ 'commands',
            \ ]

" Ale
"let g:ale_set_loclist = 0
"let g:ale_set_quickfix = 1
"let g:ale_open_list = 1
let g:ale_sign_column_always = 1

" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#file#enable_buffer_path = 1
let g:neosnippet#enable_completed_snippet = 1

" Neoformat
let g:neoformat_javascript_prettier = {
            \ 'exe': 'prettier',
            \ 'args': ['--stdin', '--single-quote', 'true', '--trailing-comma', 'es5', '--arrow-parens', 'true'],
            \ 'stdin': 1,
            \ }

" format on save
"augroup fmt
  "autocmd!
  ""autocmd BufWritePre *.js,*.py,*.elm Neoformat
  "autocmd BufWritePre *.js Neoformat prettier
"augroup END

" Airline
let g:airline_section_z="%l/%c"
let g:airline_theme='neodark'
"
" Disable git changes
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#branch#enabled = 0 " Disable branch

" Polyglot
let g:polyglot_disabled = ['elm', 'javascript']

" LanguageClient
" Automatically start language servers.
"let g:LanguageClient_serverCommands = {
      "\ 'javascript.jsx': ['javascript-typescript-stdio'],
    "\ }
"let g:LanguageClient_autoStart = 1

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
