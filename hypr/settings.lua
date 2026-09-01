local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 6,
		border_size = 2,
		col = {
			active_border = "rgba(E17A3Fee)",
			inactive_border = "rgba(58534C99)",
		},
		resize_on_border = true,
		extend_border_grab_area = 10,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		active_opacity = 1.0,
		inactive_opacity = 0.95,
		shadow = {
			enabled = true,
			range = 14,
			render_power = 3,
			color = 0x99131210,
		},
		blur = {
			enabled = true,
			size = 7,
			passes = 2,
			vibrancy = 0.12,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = true,
	},
	input = {
		kb_file = config_home .. "/hypr/keymap.xkb",
		numlock_by_default = true,
		repeat_rate = 50,
		repeat_delay = 250,
		follow_mouse = 1,
		accel_profile = "flat",
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
			disable_while_typing = true,
		},
	},
	gestures = {
		workspace_swipe_distance = 500,
	},
	misc = {
		focus_on_activate,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = false,
		animate_manual_resizes = true,
		enable_swallow = true,
		swallow_regex = "^(kitty)$",
		allow_session_lock_restore = true,
	},
	binds = {
		scroll_event_delay = 250,
		movefocus_cycles_fullscreen = true,
		window_direction_monitor_fallback = false,
	},
})

hl.curve("cinder", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("cinderFast", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 4.5, bezier = "cinder", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "cinderFast", style = "popin 92%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "cinder" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "cinder" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "cinder", style = "slidefade 12%" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "cinder", style = "fade" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
