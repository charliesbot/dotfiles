local lsp = require("lsp-zero")
local null_ls = require("null-ls")
local mason = require("mason")
local mason_null_ls = require("mason-null-ls")

lsp.preset("recommended")

lsp.ensure_installed({
  "tsserver", "eslint",
  "sumneko_lua",
  "rust_analyzer",
  "clangd",
})

mason.setup()
mason_null_ls.setup({
  ensure_installed = { "stylua", "prettier", "fixjson" },
  automatic_installation = false,
  automatic_setup = true,
})

-- Fix Undefined global 'vim'
lsp.configure("sumneko_lua", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

lsp.configure("clangd", {
  capabilities = {
    offsetEncoding = "utf-8",
  },
})

-- Flutter already has its lsp as part of the framework
lsp.setup_servers({ "dartls", force = true })

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<C-y>"] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif has_words_before() then
      cmp.complete()
    else
      fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
    end
  end, { "i", "s" }),
  ["<S-Tab>"] = cmp.mapping(function()
    if cmp.visible() then
      cmp.select_prev_item()
    end
  end, { "i", "s" }),
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp', keyword_length = 0 },
    { name = 'buffer', keyword_length = 3 },
    { name = 'luasnip', keyword_length = 2 },
  }
})


lsp.set_preferences({
  suggest_lsp_servers = false,
  set_lsp_keymaps = { omit = { '<C-k>', } },
  sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = "I",
  }
  -- sign_icons = {
  --   error = "E",
  --   warn = "W",
  --   hint = "H",
  --   info = "I",
  -- },
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>m", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
end)

lsp.nvim_workspace()

local formatting = null_ls.builtins.formatting
-- local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion
local null_sources = {
  completion.spell,
  -- diagnostics.eslint,
  formatting.prettier,
  formatting.rustfmt,
  formatting.dart_format,
  formatting.stylua.with({ extra_args = { "--indent_type", "Spaces", "indent_width", "2" } }),
}

local function format_on_save(client, bufnr)
  if client.supports_method('textDocument/formatting') then
    vim.api.nvim_clear_autocmds({
      group = augroup,
      buffer = bufnr,
    })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end
end

null_ls.setup({
  debug = false,
  sources = null_sources,
  on_attach = format_on_save
})

mason_null_ls.setup_handlers {
  -- All sources with no handler get passed here
  function(source_name, methods)
    -- To keep the original functionality of `automatic_setup = true`,
    -- please add the below.
    require("mason-null-ls.automatic_setup")(source_name, methods)
  end,
}

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = false,
  underline = true,
  update_in_insert = false,
  float = {
    source = "always", -- Or "if_many"
  },
})
