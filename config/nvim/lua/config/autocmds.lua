-- Autocommands. See `:help lua-guide-autocommands`.

-- Highlight yanked text briefly.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('rebuild-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- C / C++ alignment rules that treesitter indent does not cover well.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  group = vim.api.nvim_create_augroup('rebuild-c-indent', { clear = true }),
  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.cinoptions = ':0,l1,g0,N-s,(0,w1,W4'
  end,
})
