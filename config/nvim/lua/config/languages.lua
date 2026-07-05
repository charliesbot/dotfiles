-- Language loader. Reads every lua/languages/*.lua spec and collects the parts
-- each subsystem needs. Adding a language is a single new file in lua/languages/.
--
-- Spec shape (all fields optional except what a language needs):
--   server     = 'lua_ls'  OR  { name = 'lua_ls', settings = {...}, cmd = {...} }
--   mason      = { 'stylua' }          -- extra tools (formatters/linters); the
--                                         server itself is auto-added to installs
--   parsers    = { 'lua' }             -- treesitter (wired in a later step)
--   formatters = { lua = { 'stylua' } }-- conform, by filetype (later step)
--   linters    = { ... }               -- nvim-lint, by filetype (later step)

local M = {}

function M.load()
  local servers = {} -- name -> lsp config (without `name`)
  local mason = {} -- flat list of tools to ensure installed
  local parsers = {} -- treesitter parser names
  local formatters = {} -- filetype -> { formatter, ... }
  local linters = {} -- filetype -> { linter, ... }

  for _, file in ipairs(vim.api.nvim_get_runtime_file('lua/languages/*.lua', true)) do
    local ok, spec = pcall(dofile, file)
    if ok and type(spec) == 'table' then
      if spec.server then
        local name = type(spec.server) == 'table' and spec.server.name or spec.server
        local cfg = type(spec.server) == 'table' and vim.deepcopy(spec.server) or {}
        cfg.name = nil
        servers[name] = cfg
        -- The server itself is installed via mason-lspconfig (which maps the
        -- lspconfig name to the mason package). `mason` here is only extra tools.
      end
      for _, tool in ipairs(spec.mason or {}) do
        table.insert(mason, tool)
      end
      vim.list_extend(parsers, spec.parsers or {})
      for ft, list in pairs(spec.formatters or {}) do
        formatters[ft] = list
      end
      for ft, list in pairs(spec.linters or {}) do
        linters[ft] = list
      end
    else
      vim.notify('languages: failed to load ' .. file, vim.log.levels.WARN)
    end
  end

  return {
    servers = servers,
    mason = mason,
    parsers = parsers,
    formatters = formatters,
    linters = linters,
  }
end

return M
