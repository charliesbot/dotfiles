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
    -- Provides the completion capabilities we broadcast to servers below.
    'saghen/blink.cmp',
  },
  config = function()
    local langs = require('config.languages').load()

    -- Unified hover (VSCode-style): show the diagnostics at the cursor AND the
    -- LSP hover (type / docs) together in a single floating popup, so you never
    -- have to choose which to look at.
    local function unified_hover()
      local bufnr = vim.api.nvim_get_current_buf()
      local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })
      local clients = vim.lsp.get_clients { bufnr = bufnr }
      local enc = clients[1] and clients[1].offset_encoding or 'utf-16'
      local params = vim.lsp.util.make_position_params(0, enc)
      local severity = { 'Error', 'Warn', 'Info', 'Hint' }

      vim.lsp.buf_request_all(bufnr, 'textDocument/hover', params, function(results)
        local lines = {}

        -- Diagnostics first.
        for _, d in ipairs(diagnostics) do
          local tag = severity[d.severity] or 'Diagnostic'
          if d.source then
            tag = tag .. ' (' .. d.source .. (d.code and (': ' .. tostring(d.code)) or '') .. ')'
          end
          table.insert(lines, '**' .. tag .. '**')
          vim.list_extend(lines, vim.split(d.message, '\n', { trimempty = false }))
          table.insert(lines, '')
        end

        -- Then the LSP hover contents.
        local hover_lines = {}
        for _, res in pairs(results or {}) do
          if res.result and res.result.contents then
            vim.list_extend(hover_lines, vim.lsp.util.convert_input_to_markdown_lines(res.result.contents))
          end
        end
        if #hover_lines > 0 then
          if #lines > 0 then
            table.insert(lines, '---')
          end
          vim.list_extend(lines, hover_lines)
        end

        while #lines > 0 and lines[#lines] == '' do
          table.remove(lines)
        end
        if #lines == 0 then
          return
        end

        vim.lsp.util.open_floating_preview(lines, 'markdown', {
          border = 'rounded',
          focusable = true,
          focus_id = 'unified-hover',
          max_width = 90,
        })
      end)
    end

    -- Buffer-local keymaps when a server attaches. Minimal set on purpose.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('rebuild-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, fn, desc)
          vim.keymap.set('n', keys, fn, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('gd', vim.lsp.buf.definition, 'Goto definition')
        map('gD', vim.lsp.buf.declaration, 'Goto declaration')
        map('gh', unified_hover, 'Hover (type + diagnostics)')
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
      -- No inline text (overflows) and no virtual lines (shifts the code). The
      -- message shows in the unified `gh` popup and in the jump float.
      virtual_text = false,
    }

    -- Per-server config (settings, cmd overrides). Broadcast blink.cmp's
    -- completion capabilities to every server. Set before enabling below.
    local capabilities = require('blink.cmp').get_lsp_capabilities()
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
