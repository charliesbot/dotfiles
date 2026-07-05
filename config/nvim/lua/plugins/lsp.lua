-- Native LSP (Neovim 0.11+ vim.lsp.config / vim.lsp.enable), fed by the language
-- loader. Mason installs servers and tools. Keymaps are minimal and buffer-local.

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
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

    -- Capabilities. Swapped to blink.cmp capabilities in step 4b.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    vim.lsp.config('*', { capabilities = capabilities })
    for name, cfg in pairs(langs.servers) do
      vim.lsp.config(name, cfg)
    end

    -- Install servers + tools. We lazy-load on BufReadPre, after VimEnter, so
    -- mason-tool-installer's run_on_start hook is missed; trigger it explicitly.
    require('mason-tool-installer').setup { ensure_installed = langs.mason, run_on_start = false }
    require('mason-lspconfig').setup { ensure_installed = {}, automatic_enable = false }
    pcall(vim.cmd, 'MasonToolsInstall')

    vim.lsp.enable(vim.tbl_keys(langs.servers))
  end,
}
