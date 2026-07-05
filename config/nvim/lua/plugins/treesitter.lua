-- Treesitter: syntax highlighting and indentation (nvim-treesitter main branch).
-- The repo was archived in April 2026, so we pin to a known-good commit and treat
-- it as frozen. See modern-ai-nvim.md, "Treesitter after the archival".
-- Parser list is hardcoded here for now; the language-pack loader will feed it in
-- a later step.

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  commit = '4916d6592ede8c07973490d9322f187e07dfefac',
  build = ':TSUpdate',
  main = 'nvim-treesitter',
  init = function()
    -- Start treesitter and use its indentation on every buffer that has a parser.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('rebuild-treesitter', { clear = true }),
      callback = function()
        pcall(vim.treesitter.start)
        if vim.bo.filetype ~= 'ruby' then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    local ensure_installed = {
      'bash',
      'c',
      'cpp',
      'diff',
      'go',
      'gomod',
      'html',
      'javascript',
      'kotlin',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'rust',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
    }

    -- Install any missing parsers, deferred so it does not block startup.
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
