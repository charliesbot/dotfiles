local DATA_PATH = vim.fn.stdpath('data')

local function documentHighlight(client, bufnr)
    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceText cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
    end
end

-- *****************************************************************************
-- DART
-- *****************************************************************************
require'lspconfig'.dartls.setup {init_options = {documentFormatting = true}}

-- *****************************************************************************
-- TYPESCRIPT
-- *****************************************************************************
require'lspconfig'.tsserver.setup {
    cmd = {
        DATA_PATH .. "/lspinstall/typescript/node_modules/.bin/typescript-language-server",
        "--stdio"
    },
    on_attach = documentHighlight,
    -- This makes sure tsserver is not used for formatting (I prefer prettier)
    -- on_attach = require'lsp'.common_on_attach,
    settings = {documentFormatting = false}
}

-- *****************************************************************************
-- LUA
-- *****************************************************************************
-- https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
local sumneko_root_path = DATA_PATH .. "/lspinstall/lua"
local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"

require'lspconfig'.sumneko_lua.setup {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    on_attach = documentHighlight,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim) version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';')
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                },
                maxPreload = 10000
            }
        }
    }
}

-- *****************************************************************************
-- EFM

local efm_prettier = {
    formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}
-- local prettier = require "efm/prettier"
-- local eslint = require "efm/eslint"

local languages = {
    lua = {lua_efm},
    css = {efm_prettier},
    html = {efm_prettier},
    javascript = {efm_prettier},
    javascriptreact = {efm_prettier},
    typescript = {efm_prettier},
    typescriptreact = {efm_prettier},
    json = {efm_prettier}
}

local on_eft_attach = function(client)
    if client.resolved_capabilities.document_formatting then
        print("Hi")
        vim.api.nvim_exec([[
         augroup LspAutocommands
             autocmd! * <buffer>
             autocmd BufWritePre <buffer> LspFormatting
         augroup END
         ]], true)
    end
end

-- require"lspconfig".efm.setup {
-- init_options = {documentFormatting = true, codeAction = false},
-- on_attach = on_eft_attach,
-- cmd = {DATA_PATH .. "/lspinstall/efm/efm-langserver"},
-- filetypes = vim.tbl_keys(languages),
-- settings = {rootMarkers = {".git"}, languages = languages, log_level = 1}
-- }
