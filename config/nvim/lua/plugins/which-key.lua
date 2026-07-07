-- which-key: when you pause on a prefix key (leader, g, s, [, ]...), a popup lists
-- every key that can follow, with its description. It reads the `desc` set on our
-- keymaps, so it is a live, self-updating cheatsheet. Discovery-only: type the
-- sequence quickly and no popup appears.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {},
}
