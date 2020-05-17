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
Plug 'sainnhe/gruvbox-material'
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'ayu-theme/ayu-vim'
Plug 'skielbasa/vim-material-monokai'
Plug 'haishanh/night-owl.vim'
Plug 'nightsense/snow'
Plug 'arcticicestudio/nord-vim'
Plug 'phanviet/vim-monokai-pro'
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
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
" Plug 'ryanoasis/vim-devicons'
" Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
Plug 'matze/vim-move'
Plug 'dominikduda/vim_current_word'
Plug 'tpope/vim-repeat'
Plug 'Konfekt/FastFold'
Plug 'metakirby5/codi.vim'

" Language Support
Plug 'hail2u/vim-css3-syntax'
Plug 'sheerun/vim-polyglot'
Plug 'reasonml-editor/vim-reason-plus', { 'do': 'npm i -g ocaml-language-server' }
Plug 'gabrielelana/vim-markdown', { 'for': ['markdown'] }
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'

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

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'liuchengxu/vista.vim'

call plug#end()

" *** Settings
source ~/.config/nvim/config/settings.vim
" ********


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
let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_enable_italic = 1
let g:neodark#solid_vertsplit = 1
let g:materialmonokai_italic = 1
let g:dracula_italic = 1
let ayucolor="mirage"
set background=dark
set t_ut=

" colorscheme gruvbox
" colorscheme PaperColor
" colorscheme one
" colorscheme neodark
" colorscheme nova
" colorscheme onedark
" colorscheme cobalt2
" colorscheme quantum
" colorscheme ayu
" colorscheme onehalfdark
" colorscheme material-monokai
colorscheme dracula
" colorscheme gruvbox-material
" colorscheme nord
" colorscheme night-owl
" colorscheme snow
" colorscheme monokai_pro
"*****************************************************************************
"" Mappings
"*****************************************************************************
map <C-b> :NERDTreeToggle<CR>
" fzf file fuzzy search that respects .gitignore
" If in git directory, show only files that are committed, staged, or unstaged
" else use regular :Files
nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached')."\<cr>"
" nnoremap <C-p> :Files<CR>
nnoremap <C-f> :Find<CR>
" LSP
nmap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gD :call CocAction('jumpDefinition', 'vsplit')<CR>
nnoremap <silent> gh :call CocAction('doHover')<CR>
nmap <silent> <Leader>m <Plug>(coc-diagnostic-prev)
nmap <silent> <Leader>n <Plug>(coc-diagnostic-next)
" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
nmap <leader>rn <Plug>(coc-rename)

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

inoremap jj <ESC>

" search current word under cursor
nnoremap <silent> <Leader>f :Find <C-R><C-W><CR>

" replace text under cursor
nnoremap <silent><Leader>r :%s/<C-R><C-W>/

nnoremap zC zM
nnoremap zO zR

nnoremap zz <C-w>|

" Have the indent commands re-highlight the last visual selection to make
" multiple indentations easier
vnoremap > >gv
vnoremap < <gv

inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

" Clear search highlight
nnoremap <esc> :noh<return><esc>

nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F

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
noremap <leader>es :tabe ~/.config/nvim/coc-settings.json<CR>
noremap <leader>s :source ~/.config/nvim/init.vim<CR>
noremap <leader>et :tabe ~/.tmux.conf<CR>
noremap <leader>eg :tabe ~/.gitconfig<CR>
noremap <leader>ec :tabe ~/dotfiles/cheatsheets/vim-dirvish.md<CR>
noremap <leader>ek :tabe ~/Library/Preferences/kitty/kitty.conf<CR>

map gcc <plug>NERDCommenterToggle
map gcm <plug>NERDCommenterMinimal

"*****************************************************************************
"" Configs
"*****************************************************************************

" NerdCommenter
let NERDSpaceDelims = 1

" Vim multiple cursors
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-m>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" Vim-Sneak
let g:sneak#s_next = 1
let g:sneak#label = 1

" Magit
let g:magit_show_magit_mapping='<leader>m'

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
" let g:SuperTabContextDefaultCompletionType = '<c-n>'
" let g:SuperTabDefaultCompletionType = '<C-n>'

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

" Airline
let g:airline_section_z="%l/%c"
"let g:airline_theme='neodark'

" Disable git changes
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#branch#enabled = 0 " Disable branch

" Polyglot
let g:polyglot_disabled = ['css', 'markdown']

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
" command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

command! -bang -nargs=* Find
  \ call fzf#vim#grep(
  \ "rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
  \ {'options': '--delimiter : --nth 4..'},
  \ <bang>0)

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)


let g:fzf_colors =
      \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', ''],
      \ 'fg+':     ['fg', ''],
      \ 'bg+':     ['bg', ''],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }

" ----------------------------
" ---- File type settings ----
" ----------------------------
autocmd BufNewFile,BufRead .env.* set filetype=sh

" autocmd FileType python let b:coc_root_patterns = ['Pipfile', '.env', '.git']
" autocmd FileType python let b:coc_root_patterns = ['Pipfile']
