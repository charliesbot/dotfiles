local wezterm = require "wezterm"

return {
  font = wezterm.font({
    family = "JetBrains Mono",
    harfbuzz_features = {
      "ss02=1",
    },
  }),
  font_size = 15,
  color_scheme = "Catppuccin Mocha",
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  keys = {
    { key = '/', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment, },
  },
}
