-- Treesitter parsers + highlighting via tree-sitter-manager.
-- Neovim 0.12 core provides the treesitter runtime; this plugin installs parsers
-- and queries and auto-registers highlighting. Replaces the archived
-- nvim-treesitter. Requires the tree-sitter CLI + a C compiler (in the brew setup).
--
-- Commands: :TSManager (TUI), :TSInstall, :TSUninstall, :TSUpdate
--
-- Note: parser list is hardcoded here for now; the language loader can feed it later.

return {
  'romus204/tree-sitter-manager.nvim',
  lazy = false,
  config = function()
    require('tree-sitter-manager').setup {
      ensure_installed = {
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
      },
      -- Install a parser automatically the first time a new filetype is opened.
      auto_install = true,
      highlight = true,
    }
  end,
}
