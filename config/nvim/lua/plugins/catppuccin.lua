-- Colorscheme. Loaded early (high priority) so treesitter highlights have real
-- colors. Integrations are enabled as their plugins arrive in later steps.

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      integrations = {
        treesitter = true,
        native_lsp = { enabled = true },
      },
    }
    vim.cmd.colorscheme 'catppuccin-mocha'
  end,
}
