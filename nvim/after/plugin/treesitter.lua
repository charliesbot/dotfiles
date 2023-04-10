local rainbow = require 'ts-rainbow'

require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "vimdoc", "cpp", "c", "lua", "rust", "typescript", "javascript", "dart", "kotlin", "css",
    "python",
    "json", "tsx" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  rainbow = {
    query = {
      'rainbow-parens',
      html = 'rainbow-tags'
    },
    strategy = {
      rainbow.strategy.global,
      commonlisp = rainbow.strategy['local'],
    },
  },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
