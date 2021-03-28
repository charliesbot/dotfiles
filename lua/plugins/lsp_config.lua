local opts = { noremap=true, silent=true }

local keymap = vim.api.nvim_buf_set_keymap

local nvim_lsp = require("lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
  keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  keymap(bufnr, 'n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  keymap(bufnr, 'n', '<space>m', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  keymap(bufnr, 'n', '<space>n', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.fn.sign_define("LspDiagnosticsSignError", {text = "✗"})
  vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "!"})
  vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "•"})
  vim.fn.sign_define("LspDiagnosticsSignHint", {text = "•"})
end

nvim_lsp.tsserver.setup{
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {documentFormatting = false},
}
