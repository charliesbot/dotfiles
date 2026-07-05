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
    -- Parsers for coding languages come from the language loader; add a base set
    -- for docs/editor filetypes that have no language file of their own.
    local parsers = { 'vim', 'vimdoc', 'query', 'diff', 'html' }
    vim.list_extend(parsers, require('config.languages').load().parsers)

    local seen, ensure_installed = {}, {}
    for _, p in ipairs(parsers) do
      if not seen[p] then
        seen[p] = true
        ensure_installed[#ensure_installed + 1] = p
      end
    end

    require('tree-sitter-manager').setup {
      ensure_installed = ensure_installed,
      -- Install a parser automatically the first time a new filetype is opened.
      auto_install = true,
      highlight = true,
    }
  end,
}
