-- Git gutter signs, hunk navigation, and statusline data.
return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    attach_to_untracked = true,
    on_attach = function(buf)
      local gitsigns = require 'gitsigns'
      local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
      end

      map(']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, 'Next hunk')
      map('[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, 'Previous hunk')
    end,
  },
}
