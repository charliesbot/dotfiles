-- snacks.nvim: the UI core. For now only the two navigation tools are enabled:
--   picker   -> fuzzy file finder (VSCode-style Ctrl-P) and grep
--   explorer -> toggleable sidebar tree for browsing the codebase
-- Dashboard, zen, dim, notifier, etc. arrive in the focus step.

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
