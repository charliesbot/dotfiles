-- harpoon: pin the handful of files a task revolves around and jump between them
-- with one key. The pin list persists per project. This is the primary way to move
-- between files, ahead of the picker.
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    -- LazyVim-style keys: <leader>h menu, <leader>H add (all under leader).
    vim.keymap.set('n', '<leader>H', function()
      harpoon:list():add()
    end, { desc = 'Harpoon add file' })

    vim.keymap.set('n', '<leader>h', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon menu' })

    for i = 1, 5 do
      vim.keymap.set('n', '<leader>' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Harpoon to file ' .. i })
    end
  end,
}
