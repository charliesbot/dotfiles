-- VSCode-style, keyboard-driven review of branch and worktree changes.
return {
  'esmuellert/codediff.nvim',
  cmd = 'CodeDiff',
  opts = {},
  keys = {
    {
      '<leader>sr',
      '<cmd>CodeDiff main...<cr>',
      desc = 'Review branch against main',
    },
  },
}
