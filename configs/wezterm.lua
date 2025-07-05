local wezterm = require 'wezterm'

local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font_size = 19
config.font = wezterm.font("JetBrainsMono NF")
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "NONE"
config.automatically_reload_config = false
config.swallow_mouse_click_on_window_focus = true
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.use_fancy_tab_bar = false

config.adjust_window_size_when_changing_font_size = false

config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
	{ key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "n", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "CTRL", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "X", mods = "CTRL", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "=", mods = "CTRL", action = wezterm.action.ResetFontSize },
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
	{ key = "\\", mods = "CTRL", action = wezterm.action.ActivateCopyMode },
	{ key = "Backspace", mods = "CTRL", action = wezterm.action.SendKey({ mods = "CTRL", key = "w" }) },
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

config.tab_bar_at_bottom = true

config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│┃*…$"
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = true

return config

