local wezterm = require "wezterm"

return {
  font = wezterm.font({
    family = "MonoLisa",
    harfbuzz_features = {
      "ss02=1",
    },
  }),
  font_size = 15,
  color_scheme = "Catppuccin Mocha",
  hide_tab_bar_if_only_one_tab = true,
  keys = {
    { key = '/', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment, },
  },
}
