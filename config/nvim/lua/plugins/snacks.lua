-- snacks.nvim: the UI core.
--   picker    -> fuzzy file finder (VSCode-style Ctrl-P) and grep
--   explorer  -> toggleable sidebar tree for browsing the codebase
--   dashboard -> calm start screen (Restore Session button removed)
-- Dashboard icons use byte escapes (\xNN) so the Nerd Font glyphs survive editing.

-- Toggle the explorer sidebar from anywhere: close it if open, else open it.
local function toggle_explorer()
  for _, picker in ipairs(Snacks.picker.get { source = 'explorer' }) do
    picker:close()
    return
  end
  Snacks.explorer()
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      enabled = true,
      sources = {
        -- Let <C-b> also close the explorer while it is focused, so the same
        -- key toggles it whether focus is in the tree or in your code.
        explorer = {
          win = {
            list = { keys = { ['<C-b>'] = 'close' } },
            input = { keys = { ['<C-b>'] = { 'close', mode = { 'i', 'n' } } } },
          },
        },
      },
    },
    explorer = { enabled = true },
    -- Focus environment + quality-of-life.
    dashboard = {
      enabled = true, -- calm start screen (recent files/projects)
      -- Default buttons, minus "Restore Session" (sessions are not used here).
      preset = {
        keys = {
          { icon = '\xef\x80\x82 ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
          { icon = '\xef\x85\x9b ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = '\xef\x80\xa2 ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = '\xef\x83\x85 ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = '\xef\x90\xa3 ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = '\xf3\xb0\x92\xb2 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
          { icon = '\xef\x90\xa6 ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
    },
    notifier = { enabled = true }, -- nicer notifications
    bigfile = { enabled = true }, -- disable heavy features on huge files
    quickfile = { enabled = true }, -- render a file before plugins load
  },
  keys = {
    -- Jump to a file you know, scoped to the current workspace (cwd), frecency-ranked.
    {
      '<C-p>',
      function()
        Snacks.picker.smart { filter = { cwd = true } }
      end,
      desc = 'Find files (workspace)',
    },
    -- Search file contents across the project.
    {
      '<C-f>',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep project',
    },
    -- Toggle the explorer sidebar.
    { '<C-b>', toggle_explorer, desc = 'Explorer (toggle sidebar)' },
  },
}
