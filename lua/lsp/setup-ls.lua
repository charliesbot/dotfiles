local DATA_PATH = vim.fn.stdpath('data')
local lspconfig = require 'lspconfig'
local lspconfigs = require 'lspconfig/configs'

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
-- BASH
-- *****************************************************************************
require'lspconfig'.bashls.setup {
    cmd = {DATA_PATH .. "/lspinstall/bash/node_modules/.bin/bash-language-server", "start"},
    filetypes = {"sh", "zsh"}
}

-- *****************************************************************************
-- CPP
-- *****************************************************************************
-- require'lspconfig'.clangd.setup {
-- cmd = {DATA_PATH .. "/lspinstall/cpp/clangd/bin/clangd", "--background-index"},
-- filetypes = {"c", "cpp", "objc", "objcpp"}
-- }

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
-- CIDER
-- *****************************************************************************
lspconfigs.ciderlsp = {
    default_config = {
        cmd = {'ciderlsp', '--tooltag=nvim-lsp', '--noforward_sync_responses'},
        filetypes = {'bzl', 'c', 'cpp', 'go', 'java', 'python', 'proto', 'sql', 'textproto'},
        root_dir = lspconfig.util.root_pattern('BUILD'),
        settings = {}
    }
}

if vim.fn.executable('ciderlsp') == 1 then
    print("funciona")
else
    print("nada!!!")
end

lspconfig.ciderlsp.setup {on_attach = documentHighlight}

vim.api.nvim_exec([[
autocmd Filetype java set omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype proto set omnifunc=v:lua.vim.lsp.omnifunc
autocmd Filetype cpp set omnifunc=v:lua.vim.lsp.omnifunc
         ]], true)

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
