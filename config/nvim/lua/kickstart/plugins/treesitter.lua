-- Treesitter: highlighting, indentation, and parser management (main branch for Neovim 0.12+)
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  main = 'nvim-treesitter',
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-setup', { clear = true }),
      callback = function()
        pcall(vim.treesitter.start)
        if vim.bo.filetype ~= 'ruby' then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    local ensure_installed = { 'bash', 'c', 'diff', 'go', 'html', 'javascript', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'tsx', 'typescript', 'vim', 'vimdoc', 'zig' }
    vim.defer_fn(function()
      local installed = require('nvim-treesitter.config').get_installed()
      local to_install = vim.iter(ensure_installed)
        :filter(function(parser)
          return not vim.tbl_contains(installed, parser)
        end)
        :totable()
      if #to_install > 0 then
        require('nvim-treesitter').install(to_install)
      end
    end, 0)
  end,
}
