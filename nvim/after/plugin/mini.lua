require('mini.comment').setup()
require('mini.ai').setup()
require('mini.cursorword').setup()
require('mini.pairs').setup()
require('mini.trailspace').setup()
require('mini.surround').setup()
require('mini.move').setup(
  {
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Move visual selection in Visual mode.
      left = '<C-h>',
      right = '<C-l>',
      down = '<C-j>',
      up = '<C-k>',

      -- Move current line in Normal mode
      line_left = '<C-h>',
      line_right = '<C-l>',
      line_down = '<C-j>',
      line_up = '<C-k>',
    },
  }
)
