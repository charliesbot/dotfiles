-- *****************************************************************************
-- Nerd Commenter
-- *****************************************************************************
vim.cmd('let NERDSpaceDelims = 1')

-- *****************************************************************************
-- Vim multiple cursors
-- *****************************************************************************
vim.g.multi_cursor_next_key = '<C-n>'
vim.g.multi_cursor_prev_key = '<C-m>'
vim.g.multi_cursor_skip_key = '<C-x>'
vim.g.multi_cursor_quit_key = '<Esc>'

-- *****************************************************************************
-- Vim Sneak
-- *****************************************************************************
vim.g['sneak#s_next'] = 1
vim.g['sneak#label'] = 1

-- *****************************************************************************
-- Vim Gutter
-- *****************************************************************************
vim.g.gitgutter_override_sign_column_highlight = 0

-- *****************************************************************************
-- NerdTree
-- *****************************************************************************
vim.g.NERDTreeHijackNetrw = 0
vim.g.nerdtree_tabs_focus_on_files = 1
vim.cmd('let NERDTreeShowHidden=1')
vim.cmd("let NERDTreeIgnore=['\\.DS_Store', '\\~$', '\\.swp']")

-- *****************************************************************************
-- Vim Move
-- *****************************************************************************
-- <C-k>   Move current line/selections up
-- <C-j>   Move current line/selections down
vim.g.move_key_modifier = 'C'

-- *****************************************************************************
-- FZF
-- *****************************************************************************
vim.g.fzf_colors = {
  fg = { 'fg', 'Normal' },
  bg = { 'bg', 'Normal', },
  hl = { 'fg', '', },
  ['fg+'] = { 'fg', '', },
  ['bg+'] = { 'bg', '' },
  ['hl+'] = { 'fg', 'Statement' },
  info = {'fg', 'PreProc'},
  prompt =  {'fg', 'Conditional'},
  pointer = {'fg', 'Exception'},
  marker =  {'fg', 'Keyword'},
  spinner = {'fg', 'Label'},
  header =  {'fg', 'Comment'}
}
vim.cmd([[
command! -bang -nargs=* Find
call fzf#vim#grep(
"rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
{'options': '--delimiter : --nth 4..'},
<bang>0)
]])

vim.cmd([[
command! -bang -nargs=? -complete=dir Files
call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
]])

-- *****************************************************************************
-- Startify
-- *****************************************************************************
vim.g.startify_change_to_vcs_root = 1
vim.g.startify_list_order = {
  {
    '   These are my sessions:'
  },
  'sessions',
  {
    '   Recently used files in the current directory:'
  },
  'dir',
  {
    '   Recently used files'
  },
  'files',
  {
    '   These are my bookmarks:'
  },
  'bookmarks',
  {
    '   These are my commands:'
  },
  'commands',
}

-- *****************************************************************************
-- Airline
-- *****************************************************************************
vim.g.airline_section_z="%l/%c"

-- Disable git changes
vim.g['airline#extensions#hunks#enabled'] = 0
vim.g['airline#extensions#branch#enabled'] = 0 -- Disable branch

