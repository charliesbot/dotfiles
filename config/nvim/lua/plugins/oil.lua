-- oil.nvim: edit the filesystem like a normal buffer.
-- `-` opens the parent directory of the current file; edit, then :w to apply.
-- lazy = false is recommended so oil can hijack netrw and open directory args.

-- Toggle the oil float: close it if we are inside it, otherwise open it.
local function toggle_oil_float()
  local win = vim.api.nvim_get_current_win()
  local in_float = vim.api.nvim_win_get_config(win).relative ~= ''
  if in_float and vim.bo.filetype == 'oil' then
    require('oil').close()
  else
    require('oil').open_float()
  end
end

return {
  'stevearc/oil.nvim',
  lazy = false,
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    -- Float panel toggle: opens over your layout, press again to close.
    { '<C-b>', toggle_oil_float, desc = 'Oil: toggle float panel' },
    -- Full window: replaces the current buffer with the parent directory.
    { '-', '<CMD>Oil<CR>', desc = 'Oil: parent directory (full window)' },
  },
}
