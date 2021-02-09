local wezterm = require 'wezterm';

return {
  font = wezterm.font("Iosevka Term"),
  color_scheme = "OceanicMaterial",
  window_padding = {
    left = 4,
    right = 4,
    top = 2,
    bottom = 3,
  },
  keys = {
    {
      key="h",
      mods="CTRL|SHIFT",
      action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}},
    },
    {
      key="v",
      mods="CTRL|SHIFT",
      action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}},
    },
    {
      key="w",
      mods="CTRL|SHIFT",
      action=wezterm.action{CloseCurrentPane={confirm=true}},
    },
    {
      key="w",
      mods="SUPER",
      action=wezterm.action{CloseCurrentTab={confirm=true}},
    },
  },
}
