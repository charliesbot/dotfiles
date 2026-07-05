-- Catppuccin theme. Installs and configures it only; activation lives in
-- lua/config/theme.lua. Integrations are enabled as their plugins arrive.

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    integrations = {
      treesitter = true,
      native_lsp = { enabled = true },
    },
  },
}
