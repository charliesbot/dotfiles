if exists('veonim')
  source ~/.config/nvim/veonim.vim
  finish
endif

source ~/.config/nvim/config/plugins.vim
source ~/.config/nvim/config/settings.vim

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

" colorscheme gruvbox
" colorscheme PaperColor
" colorscheme one
" colorscheme neodark
" colorscheme nova
" colorscheme onedark
" colorscheme cobalt2
" colorscheme quantum
" colorscheme ayu
" colorscheme material-monokai
colorscheme dracula
" colorscheme night-owl
" colorscheme OceanicNext
" colorscheme snow
" colorscheme monokai_pro

"*****************************************************************************
"" Mappings
"*****************************************************************************
map <C-b> :NERDTreeToggle<CR>
nnoremap <C-p> :GitFiles<CR>
nnoremap <C-P> :FZF<CR>
nnoremap <leader>ff :Files<cr>
nnoremap <leader>fb :Buffers<cr>
nnoremap <leader>fg :GFiles<cr>
nnoremap <C-f> :Find<space>
" LSP
nmap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gh :call CocAction('doHover')<CR>
nmap <silent> <Leader>m <Plug>(coc-diagnostic-prev)
nmap <silent> <Leader>n <Plug>(coc-diagnostic-next)
" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
nmap <leader>rn <Plug>(coc-rename)

inoremap jj <ESC>

" search current word under cursor
nnoremap <silent> <Leader>ag :Find <C-R><C-W><CR>

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

noremap <Leader>f :Neoformat<CR>

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

"*****************************************************************************
"" Configs
"*****************************************************************************

" NerdCommenter
let NERDSpaceDelims = 1

" Neoformat
let g:neoformat_basic_format_align = 1
let g:neoformat_basic_format_retab = 1
let g:neoformat_basic_format_trim = 1
let g:neoformat_enabled_typescript = ['prettier']
let g:neoformat_enabled_python = ['black']

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
let g:SuperTabContextDefaultCompletionType = '<c-n>'
let g:SuperTabDefaultCompletionType = '<C-n>'

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
let g:polyglot_disabled = ['typescript', 'tsx', 'css', 'markdown']

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
autocmd BufNewFile,BufRead *.*rc set filetype=json
autocmd BufNewFile,BufRead .env.* set filetype=sh

autocmd FileType python let b:coc_root_patterns = ['.git', '.env']
