-- Format on save. Formatters per filetype come from the language loader, so
-- adding a language's formatter is just its lua/languages/<lang>.lua file.
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  config = function()
    local langs = require('config.languages').load()
    require('conform').setup {
      notify_on_error = false,
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
      formatters_by_ft = langs.formatters,
    }
  end,
}
