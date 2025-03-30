local wezterm = require("wezterm")
local mappings = require("modules.mappings")

-- Show which key table is active in the status area
wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()
	if name then
		name = "TABLE: " .. name
	end
	window:set_right_status(name or "")
end)
return {
  default_cursor_style = "BlinkingBlock",
  colors = {
    background = "#282828", -- Gruvbox dark background
    foreground = "#ebdbb2", -- Gruvbox dark foreground
    cursor_bg = "#d4be98",
    cursor_fg = "#282828",
    ansi = { "#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984" },
    brights = { "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2" },
  },
	-- font
	font = wezterm.font("JetBrains Mono", { weight = "Medium" }),
	font_size = 10,
	line_height = 1,
	window_background_opacity = 0.98,
	-- tab bar
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
	tab_max_width = 999999,
	window_padding = {
		left = 30,
		right = 30,
		top = 30,
		bottom = 30,
	},
	window_decorations = "RESIZE",
	inactive_pane_hsb = {
		brightness = 0.7,
	},
	send_composed_key_when_left_alt_is_pressed = false,
	send_composed_key_when_right_alt_is_pressed = true,
	-- key bindings
	leader = mappings.leader,
	keys = mappings.keys,
	key_tables = mappings.key_tables,
}
