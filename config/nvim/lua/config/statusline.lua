-- Native statusline. No plugin. Adapts to any colorscheme: the mode block colors
-- are derived from the theme's own highlight groups on every ColorScheme, and the
-- rest uses existing groups (Diagnostic*, Comment). Global (laststatus = 3).
--
-- Layout:
--   MODE  branch  file.ts [+]           8   3   1   filetype  12:34  45%

local M = {}

-- Nerd Font glyphs as byte escapes so they survive editing (\xNN, not literals).
local BRANCH = '\xee\x82\xa0' --
local LSP = '\xf3\xb0\x9a\xa9' -- U+F06A9

local diag = {
  { sev = vim.diagnostic.severity.ERROR, icon = '\xef\x81\x97', hl = 'DiagnosticError' }, --
  { sev = vim.diagnostic.severity.WARN, icon = '\xef\x81\xb1', hl = 'DiagnosticWarn' }, --
  { sev = vim.diagnostic.severity.INFO, icon = '\xef\x81\x9a', hl = 'DiagnosticInfo' }, --
  { sev = vim.diagnostic.severity.HINT, icon = '\xef\x83\xab', hl = 'DiagnosticHint' }, --
}

local mode_map = {
  n = 'NORMAL',
  no = 'O-PENDING',
  nov = 'O-PENDING',
  noV = 'O-PENDING',
  niI = 'NORMAL',
  niR = 'NORMAL',
  niV = 'NORMAL',
  v = 'VISUAL',
  V = 'V-LINE',
  ['\22'] = 'V-BLOCK', -- <C-v>
  s = 'SELECT',
  S = 'S-LINE',
  ['\19'] = 'S-BLOCK', -- <C-s>
  i = 'INSERT',
  ic = 'INSERT',
  ix = 'INSERT',
  R = 'REPLACE',
  Rv = 'V-REPLACE',
  c = 'COMMAND',
  cv = 'EX',
  r = 'PROMPT',
  rm = 'MORE',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  t = 'TERMINAL',
}

-- Which highlight group each mode uses for its colored block.
local mode_hl = {
  n = 'StlModeNormal',
  no = 'StlModeNormal',
  nov = 'StlModeNormal',
  noV = 'StlModeNormal',
  niI = 'StlModeNormal',
  niR = 'StlModeNormal',
  niV = 'StlModeNormal',
  v = 'StlModeVisual',
  V = 'StlModeVisual',
  ['\22'] = 'StlModeVisual',
  s = 'StlModeVisual',
  S = 'StlModeVisual',
  ['\19'] = 'StlModeVisual',
  i = 'StlModeInsert',
  ic = 'StlModeInsert',
  ix = 'StlModeInsert',
  R = 'StlModeReplace',
  Rv = 'StlModeReplace',
  c = 'StlModeCommand',
  cv = 'StlModeCommand',
  t = 'StlModeTerminal',
}

-- Borrow each mode color from an existing theme group so it tracks the colorscheme.
local mode_source = {
  StlModeNormal = 'Function',
  StlModeInsert = 'String',
  StlModeVisual = 'Keyword',
  StlModeReplace = 'DiagnosticError',
  StlModeCommand = 'Constant',
  StlModeTerminal = 'Type',
}

local function setup_hl()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local text = normal.bg or 0x1e1e2e -- dark text on the colored block
  for group, source in pairs(mode_source) do
    local src = vim.api.nvim_get_hl(0, { name = source, link = false })
    local color = src.fg or normal.fg or 0xcccccc
    vim.api.nvim_set_hl(0, group, { fg = text, bg = color, bold = true })
  end
end

local function git()
  local head = vim.b.gitsigns_head
  if head and head ~= '' then
    return '%#Constant# ' .. BRANCH .. ' ' .. head .. ' %*'
  end
  return ''
end

-- Clients that use LSP as transport but are not language servers.
local lsp_ignore = { copilot = true }

local function lsp()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if not lsp_ignore[c.name] then
      names[#names + 1] = c.name
    end
  end
  if #names == 0 then
    return ''
  end
  return '%#Comment#' .. LSP .. ' ' .. table.concat(names, ', ') .. '%*'
end

local function diagnostics()
  local c = vim.diagnostic.count(0)
  local out = {}
  for _, d in ipairs(diag) do
    local n = c[d.sev] or 0
    if n > 0 then
      out[#out + 1] = '%#' .. d.hl .. '# ' .. d.icon .. ' ' .. n .. '%*'
    end
  end
  return #out > 0 and (table.concat(out) .. ' ') or ''
end

function M.render()
  local m = vim.api.nvim_get_mode().mode
  local label = mode_map[m] or 'UNKNOWN'
  local hl = mode_hl[m] or 'StlModeNormal'
  return table.concat {
    '%#' .. hl .. '# ' .. label .. ' %*', -- colored mode block
    git(), -- git branch (empty until gitsigns)
    ' %<%t%m%r', -- filename only, modified, readonly
    '%=', -- ---- center ----
    lsp(), -- attached LSP server(s), centered
    '%=', -- ---- right ----
    diagnostics(),
    '%#Comment# %{&filetype} %*', -- filetype, subdued
    ' Ln %l, Col %c ', -- position, VSCode-style
  }
end

setup_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_hl })

vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

return M
