-- Lua. Server: lua_ls. Formatter (used from step 4c): stylua.
return {
  server = {
    name = 'lua_ls',
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
      },
    },
  },
  mason = { 'stylua' },
  parsers = { 'lua', 'luadoc' },
  formatters = { lua = { 'stylua' } },
}
