-- Native LSP (Neovim 0.11+ vim.lsp.config / vim.lsp.enable), fed by the language
-- loader. Loaded eagerly (no lazy event) so server registration happens before
-- the first file opens; the servers themselves only start when a matching file
-- is opened, so this is cheap.
--
-- mason installs binaries; mason-lspconfig maps names + auto-enables installed
-- servers; mason-tool-installer installs the non-server tools (formatters/linters).

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    local langs = require('config.languages').load()

    -- Buffer-local keymaps when a server attaches. Minimal set on purpose.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('rebuild-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, fn, desc)
          vim.keymap.set('n', keys, fn, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('gd', vim.lsp.buf.definition, 'Goto definition')
        map('gD', vim.lsp.buf.declaration, 'Goto declaration')
        map('gh', vim.lsp.buf.hover, 'Hover documentation')
      end,
    })

    -- Diagnostics appearance.
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = { source = 'if_many', spacing = 2 },
    }

    -- Per-server config (settings, cmd overrides). Capabilities become blink.cmp's
    -- in step 4b; for now the native defaults. Set before enabling below.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    vim.lsp.config('*', { capabilities = capabilities })
    for name, cfg in pairs(langs.servers) do
      vim.lsp.config(name, cfg)
    end

    -- Install + enable servers. `automatic_enable` as a list is an allowlist:
    -- mason-lspconfig enables exactly these (and handles first-run install->enable
    -- timing), instead of `true` which would also start any installed tool that
    -- ships an LSP mode, e.g. `stylua --lsp`.
    local server_names = vim.tbl_keys(langs.servers)
    require('mason-lspconfig').setup {
      ensure_installed = server_names,
      automatic_enable = server_names,
    }

    -- Install the non-server tools (formatters/linters).
    require('mason-tool-installer').setup { ensure_installed = langs.mason }
  end,
}
