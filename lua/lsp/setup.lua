local lsp_installer = require("nvim-lsp-installer")

local servers = {
    "bashls", "clangd", "html", "jsonls", "rust_analyzer", "sumneko_lua", "svelte", "tsserver"
}

for _, name in pairs(servers) do
    local ok, server = lsp_installer.get_server(name)
    -- Check that the server is supported in nvim-lsp-installer
    if ok then
        if not server:is_installed() then
            print("Installing " .. name)
            server:install()
        end
    end
end

lsp_installer.on_server_ready(function(server)
    local opts = {}

    opts.capabilities = require('cmp_nvim_lsp').update_capabilities(
                            vim.lsp.protocol.make_client_capabilities())

    -- (optional) Customize the options passed to the server
    if server.name == "tsserver" then
        -- Leave the formatting to ESLint_d via null_ls
        opts.on_attach = function(client)
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false
        end
    end

    -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
end)
