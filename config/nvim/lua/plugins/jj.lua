-- jj.nvim: native jujutsu integration rendered in nvim buffers (log, diff,
-- describe, squash/split/rebase/abandon, bookmarks, blame, PR opening).
-- Replaces the jjui terminal for a fully in-editor jj workflow.
-- Unpinned on purpose: pre-v1, but we want the latest changes.
return {
  'NicolasGB/jj.nvim',
  dependencies = { 'folke/snacks.nvim' },
  cmd = 'J',
  keys = {
    { '<leader>j', '<cmd>J log<cr>', desc = 'jj log' },
    { '<leader>J', '<cmd>J status<cr>', desc = 'jj status' },
  },
  config = function()
    require('jj').setup {
      picker = { snacks = {} },
    }
  end,
}
