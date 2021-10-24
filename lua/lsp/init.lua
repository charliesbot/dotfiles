vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

vim.fn.sign_define("LspDiagnosticsSignError", {text = "✗"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "!"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "•"})
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "•"})

--
-- SAGA
--
local saga = require 'lspsaga'
saga.init_lsp_saga {
    --[[ dianostic_header_icon = ' ● ',
    code_action_icon = '💡',
    error_sign = '🚨',
    warn_sign = '⚠',
    hint_sign = "⚡",
    infor_sign = 'I', ]]
    border_style = "round",
    code_action_keys = {quit = "<ESC>"},
    rename_action_keys = {quit = "<ESC>"}
}

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
    -- check if there is a local prettier exe or use the global one
    local prettier_exe = "./node_modules/.bin/prettier"
    if vim.fn.executable(prettier_exe) ~= 1 then prettier_exe = "npx prettier" end

    return {
        exe = prettier_exe,
        args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
        stdin = true
    }
end

function cFormatter()
    return {exe = "clang-format", args = {}, stdin = true}
end

function rustFormatter()
    return {exe = "rustfmt", args = {}, stdin = true}
end

require('formatter').setup({
    logging = false,
    filetype = {
        cpp = {cFormatter},
        css = {prettierFormatter},
        html = {prettierFormatter},
        javascript = {prettierFormatter},
        javascriptreact = {prettierFormatter},
        json = {prettierFormatter},
        lua = {luaFormatter},
        markdown = {prettierFormatter},
        svelte = {prettierFormatter},
        typescript = {prettierFormatter},
        typescriptreact = {prettierFormatter},
        rust = {rustFormatter}
    }
})

vim.api.nvim_exec([[
augroup FormatAutogroup
  autocmd!
  autocmd FileType cpp autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType html autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType css autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType json autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType javascript autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType typescript autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType typescriptreact autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType svelte autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType lua autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType markdown autocmd BufWritePost <buffer> FormatWrite
  autocmd FileType rust autocmd BufWritePost <buffer> FormatWrite
augroup END
]], true)
