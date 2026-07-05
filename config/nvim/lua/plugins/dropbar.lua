-- dropbar: a breadcrumb winbar showing the code context path, with a pickable menu.
-- (Dropped the old telescope-fzf-native dependency; dropbar works without it.)
return {
  'Bekaboo/dropbar.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local api = require 'dropbar.api'
    vim.keymap.set('n', '<leader>;', api.pick, { desc = 'Pick from dropbar' })
    vim.keymap.set('n', '[;', api.goto_context_start, { desc = 'Go to context start' })
    vim.keymap.set('n', '];', api.select_next_context, { desc = 'Select next context' })
  end,
}
