-- vcsigns.nvim: VCS-agnostic gutter signs + hunks. jj is its best-tested backend,
-- so this replaces gitsigns for a jj-primary workflow (no colocation needed).
-- Diff counts feed the statusline; see lua/config/statusline.lua.
return {
  'algmyr/vcsigns.nvim',
  dependencies = {
    'algmyr/vclib.nvim',
    'lewis6991/async.nvim',
  },
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('vcsigns').setup {
      target_commit = 1, -- good default for the jj new + squash flow
    }

    local actions = require 'vcsigns.actions'
    local map = vim.keymap.set
    map('n', ']c', function()
      actions.hunk_next(0, vim.v.count1)
    end, { desc = 'Next hunk' })
    map('n', '[c', function()
      actions.hunk_prev(0, vim.v.count1)
    end, { desc = 'Previous hunk' })
    map('n', '<leader>su', function()
      actions.hunk_undo(0)
    end, { desc = 'Undo hunk under cursor' })
    map('n', '<leader>sd', function()
      actions.toggle_hunk_diff(0)
    end, { desc = 'Toggle inline hunk diff' })
    map('n', '<leader>sv', function()
      actions.diffview(0)
    end, { desc = 'Side-by-side diff view' })
  end,
}
