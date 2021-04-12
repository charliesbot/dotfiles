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
-- BASH
-- *****************************************************************************
require'lspconfig'.bashls.setup {
    cmd = {DATA_PATH .. "/lspinstall/bash/node_modules/.bin/bash-language-server", "start"},
    filetypes = {"sh", "zsh"}
}

-- *****************************************************************************
-- CPP
-- *****************************************************************************
require'lspconfig'.clangd.setup {
    cmd = {DATA_PATH .. "/lspinstall/cpp/clangd/bin/clangd", "--background-index"},
    filetypes = {"c", "cpp", "objc", "objcpp"}
}

-- *****************************************************************************
-- DART
-- *****************************************************************************
require'lspconfig'.dartls.setup {init_options = {documentFormatting = true}}

-- *****************************************************************************
-- TYPESCRIPT
-- *****************************************************************************
require'lspconfig'.tsserver.setup {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 178f39e (run format)
    cmd = {
        DATA_PATH .. "/lspinstall/typescript/node_modules/.bin/typescript-language-server",
        "--stdio"
    },
<<<<<<< HEAD
=======
    cmd = {DATA_PATH .. "/lspinstall/typescript/node_modules/.bin/typescript-language-server", "--stdio"},
>>>>>>> 94c1409 (full migration)
=======
>>>>>>> 178f39e (run format)
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 178f39e (run format)
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                },
<<<<<<< HEAD
=======
                library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true},
>>>>>>> 94c1409 (full migration)
=======
>>>>>>> 178f39e (run format)
                maxPreload = 10000
            }
        }
    }
}

-- *****************************************************************************
-- EFM
<<<<<<< HEAD
<<<<<<< HEAD

local efm_prettier = {
    formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}
=======
-- *****************************************************************************
local lua_efm = {
    formatCommand = "lua-format -i --no-keep-simple-function-one-line --column-limit=120",
    formatStdin = true
}

local efm_prettier = {formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}", formatStdin = true}
>>>>>>> 94c1409 (full migration)
=======

local efm_prettier = {
    formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}
>>>>>>> 178f39e (run format)
-- local prettier = require "efm/prettier"
-- local eslint = require "efm/eslint"

local languages = {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 178f39e (run format)
    lua = {lua_efm},
    css = {efm_prettier},
    html = {efm_prettier},
    javascript = {efm_prettier},
    javascriptreact = {efm_prettier},
    typescript = {efm_prettier},
    typescriptreact = {efm_prettier},
    json = {efm_prettier}
<<<<<<< HEAD
}

local on_eft_attach = function(client)
    if client.resolved_capabilities.document_formatting then
=======
  lua = {lua_efm},
  css = {efm_prettier},
  html = {efm_prettier},
  javascript = {efm_prettier},
  javascriptreact = {efm_prettier},
  typescript = {efm_prettier},
  typescriptreact = {efm_prettier},
  json = {efm_prettier},
}

local on_eft_attach = function(client)
  if client.resolved_capabilities.document_formatting then
>>>>>>> 94c1409 (full migration)
=======
}

local on_eft_attach = function(client)
    if client.resolved_capabilities.document_formatting then
>>>>>>> 178f39e (run format)
        print("Hi")
        vim.api.nvim_exec([[
         augroup LspAutocommands
             autocmd! * <buffer>
             autocmd BufWritePre <buffer> LspFormatting
         augroup END
         ]], true)
    end
end

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 178f39e (run format)
-- require"lspconfig".efm.setup {
-- init_options = {documentFormatting = true, codeAction = false},
-- on_attach = on_eft_attach,
-- cmd = {DATA_PATH .. "/lspinstall/efm/efm-langserver"},
-- filetypes = vim.tbl_keys(languages),
-- settings = {rootMarkers = {".git"}, languages = languages, log_level = 1}
-- }
<<<<<<< HEAD
=======
languages['javascript.jsx'] = {efm_prettier}
languages['typescript.tsx'] = {efm_prettier}

vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")

require"lspconfig".efm.setup {
  init_options = {documentFormatting = true, codeAction = false},
  on_attach = on_eft_attach,
  cmd = {
    DATA_PATH .. "/lspinstall/efm/efm-langserver"
  },
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = {".git"},
    languages = languages, log_level = 1
  },
}

vim.api.nvim_exec([[
 autocmd BufWritePre *.ts lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.json lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.html lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.css lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.php lua vim.lsp.buf.formatting_sync(nil, 100)
 autocmd BufWritePre *.ts lua vim.lsp.buf.formatting_sync(nil, 100)
]], true)
>>>>>>> 94c1409 (full migration)
=======
>>>>>>> 178f39e (run format)
