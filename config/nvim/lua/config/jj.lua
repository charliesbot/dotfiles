-- jj bookmark indicator for the statusline. jj has no "current branch", so we
-- query the nearest bookmark reachable from @ (falling back to the short change
-- id) and cache it in vim.b.jj_bookmark. Refreshed async on buffer-enter / focus
-- / save, never on every statusline redraw (jj is too slow to call constantly).
-- `--ignore-working-copy` keeps the query from snapshotting jj's working copy.

local M = {}

local function set(buf, label)
  -- vim.system callbacks run in a fast-event context; defer buffer writes.
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.b[buf].jj_bookmark = label
      vim.cmd 'redrawstatus'
    end
  end)
end

function M.refresh(buf)
  if buf == nil or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if vim.fn.executable 'jj' == 0 then
    return
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return
  end
  local dir = vim.fn.fnamemodify(name, ':h')

  local function run(revset, template, cb)
    vim.system({
      'jj',
      'log',
      '--no-graph',
      '--ignore-working-copy',
      '--color',
      'never',
      '-r',
      revset,
      '-T',
      template,
    }, { text = true, cwd = dir }, cb)
  end

  -- Nearest bookmark in @'s ancestry; if none, the short change id.
  run('latest(bookmarks() & ::@)', 'bookmarks', function(res)
    if res.code ~= 0 then
      set(buf, '') -- not a jj repo
      return
    end
    local label = vim.trim((res.stdout or ''):gsub('%*', ''):gsub('%s+', ' '))
    if label ~= '' then
      set(buf, label)
      return
    end
    run('@', 'change_id.shortest(8)', function(res2)
      set(buf, res2.code == 0 and vim.trim(res2.stdout or '') or '')
    end)
  end)
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('jj-statusline', { clear = true }),
  callback = function(ev)
    M.refresh(ev.buf)
  end,
})

return M
