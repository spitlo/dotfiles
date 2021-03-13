local wezterm = require 'wezterm';

function font_with_fallback(name, params)
  local names = {name, "Iosevka Term", "Iosevka"}
  return wezterm.font_with_fallback(names, params)
end

return {
  font = font_with_fallback("Iosevka Term Light"),
  font_rules= {
    {
      font = font_with_fallback("Iosevka Term"),
      intensity = "Bold",
    },
    {
      font = font_with_fallback("Iosevka Term"),
      italic = true,
    },
    {
      font = font_with_fallback("Iosevka Term"),
      intensity = "Bold",
      italic = true,
    },
  },
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
