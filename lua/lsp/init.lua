vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

vim.fn.sign_define("LspDiagnosticsSignError", {text = "✗"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "!"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "•"})
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "•"})

--
-- SAGA
--
local saga = require 'lspsaga'
saga.init_lsp_saga()

--
-- FORMATTER
--

function luaFormatter()
    return {
        exe = "lua-format",
        args = {'--no-keep-simple-function-one-line', '--column-limit=100'},
        stdin = true
    }
end

function prettierFormatter()
    return {
        exe = "npx prettier",
        args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
        stdin = true
    }
end

function cFormatter()
    return {exe = "clang-format", args = {}, stdin = true}
end

require('formatter').setup({
    logging = false,
    filetype = {
        typescript = {prettierFormatter},
        javascript = {prettierFormatter},
        javascriptreact = {prettierFormatter},
        typescriptreact = {prettierFormatter},
        lua = {luaFormatter},
        cpp = {cFormatter}
    }
})

vim.api.nvim_exec([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.rs,*.lua,*.ts,*.tsx,*.cpp,*.rs,*.cc FormatWrite
augroup END
]], true)