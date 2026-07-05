-- mini.nvim modules. Currently only surround is enabled.
-- mini.ai (better textobjects) and mini.pairs (autopairs) can be added to the
-- config below later, same dependency.
--
-- Surround keys (the `s` prefix replaces the built-in substitute; use `cl`/`cc`):
--   saiw)  add () around inner word
--   sd"    delete surrounding "
--   sr"'   replace surrounding " with '
--   sf / sF find surrounding (right / left), sh highlight, sn update n_lines

return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    require('mini.surround').setup()
  end,
}
