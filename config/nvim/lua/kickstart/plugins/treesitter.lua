-- Parser installation for treesitter (highlighting/indent is native in Neovim 0.12+)
return {
  'romus204/tree-sitter-manager.nvim',
  config = function()
    require('tree-sitter-manager').setup {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'zig' },
    }
  end,
}
