local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion

require("mason-null-ls").setup({
	ensure_installed = { "stylua", "prettier", "eslint", "fixjson" },
})

null_ls.setup({
	sources = {
		formatting.prettier,
		formatting.stylua,
		diagnostics.eslint,
		completion.spell,
	},
})

null_ls.setup()
