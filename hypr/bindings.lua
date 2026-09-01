---@diagnostic disable: undefined-global

local app = "uwsm app -- "
local syncobj = " --enable-features=WaylandLinuxDrmSyncobj"
local repeating = { repeating = true }
local media = { locked = true, repeating = true }

local function bind(keys, action, description, flags)
	flags = flags or {}
	flags.description = description
	hl.bind(keys, action, flags)
end

bind("SUPER + Q", hl.dsp.window.close(), "Close window")
bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Toggle fullscreen")
bind("SUPER + SHIFT + Space", hl.dsp.window.float(), "Toggle floating")
bind("SUPER + P", hl.dsp.window.pseudo(), "Toggle pseudotile")

bind("SUPER + Space", hl.dsp.exec_cmd("mitishell launcher"), "Application launcher")
bind("SUPER + Return", hl.dsp.exec_cmd(app .. "alacritty"), "Terminal")
bind("SUPER + W", hl.dsp.exec_cmd(app .. "zen-twilight" .. syncobj), "Browser")
bind("SUPER + E", hl.dsp.exec_cmd(app .. "nautilus --new-window"), "Files")
bind("SUPER + S", hl.dsp.exec_cmd(app .. "signal-desktop" .. syncobj), "Signal")
bind("SUPER + M", hl.dsp.exec_cmd(app .. "fastmail" .. syncobj), "Fastmail")
bind("SUPER + I", hl.dsp.exec_cmd("mitishell settings"), "Desktop settings")
bind("SUPER + D", hl.dsp.exec_cmd("mitishell control"), "Desktop control center")
bind("SUPER + semicolon", hl.dsp.exec_cmd("mitishell emoji"), "Emoji picker")
bind("SUPER + A", hl.dsp.exec_cmd("mitishell actions"), "Desktop Actions")
bind("SUPER + V", hl.dsp.exec_cmd("mitishell clipboard"), "Clipboard history")
bind("SUPER + N", hl.dsp.exec_cmd("mitishell notifications dnd"), "Toggle Do Not Disturb")
bind("SUPER + CTRL + N", hl.dsp.exec_cmd("mitishell night-light toggle"), "Toggle Night Light")
bind("SUPER + CTRL + R", hl.dsp.exec_cmd("mitishell reminder"), "Set reminder")
bind("SUPER + SHIFT + slash", hl.dsp.exec_cmd("mitishell keybinds"), "Keybind help")
bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("mitishell power menu"), "Power menu")
bind("SUPER + Escape", hl.dsp.exec_cmd("loginctl lock-session"), "Lock session")
bind("SUPER + O", hl.dsp.exec_cmd("hyprpicker | wl-copy"), "Color picker")

local directions = {
	h = "left",
	j = "down",
	k = "up",
	l = "right",
}

for key, direction in pairs(directions) do
	bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }), "Focus " .. direction)
	bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }), "Move window " .. direction)
end

for workspace = 1, 8 do
	bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace }), "Workspace " .. workspace)
	bind(
		"SUPER + SHIFT + " .. workspace,
		hl.dsp.window.move({ workspace = workspace, follow = false }),
		"Move window to workspace " .. workspace
	)
end

bind("SUPER + comma", hl.dsp.focus({ monitor = "-1" }), "Previous monitor")
bind("SUPER + period", hl.dsp.focus({ monitor = "+1" }), "Next monitor")
bind("SUPER + SHIFT + comma", hl.dsp.window.move({ monitor = "-1", follow = true }), "Move to previous monitor")
bind("SUPER + SHIFT + period", hl.dsp.window.move({ monitor = "+1", follow = true }), "Move to next monitor")

bind("SUPER + CTRL + h", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), "Shrink width", repeating)
bind("SUPER + CTRL + l", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), "Grow width", repeating)
bind("SUPER + CTRL + j", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), "Grow height", repeating)
bind("SUPER + CTRL + k", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), "Shrink height", repeating)

bind("SUPER + mouse:272", hl.dsp.window.drag(), "Move window with mouse", { mouse = true })
bind("SUPER + mouse:273", hl.dsp.window.resize(), "Resize window with mouse", { mouse = true })

bind("Print", hl.dsp.exec_cmd("mitishell capture region"), "Region screenshot")
bind("CTRL + Print", hl.dsp.exec_cmd("mitishell capture window"), "Window screenshot")
bind("SHIFT + Print", hl.dsp.exec_cmd("mitishell capture output"), "Focused output screenshot")
bind("SUPER + CTRL + Print", hl.dsp.exec_cmd("mitishell capture text"), "Extract text from region")

bind("SUPER + Print", hl.dsp.exec_cmd("mitishell record region"), "Region recording")
bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("mitishell record output"), "Output recording")

bind("F9", hl.dsp.exec_cmd("voxtype record start"), "Push-to-talk dictation")
bind("F9", hl.dsp.exec_cmd("voxtype record stop"), "Push-to-talk dictation", { release = true })

bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("mitishell volume up"), "Volume up", media)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("mitishell volume down"), "Volume down", media)
bind("XF86AudioMute", hl.dsp.exec_cmd("mitishell volume mute"), "Mute audio", media)
bind("XF86AudioMicMute", hl.dsp.exec_cmd("mitishell mic mute"), "Mute microphone", media)
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), "Play or pause", media)
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "Play or pause", media)
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), "Next track", media)
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), "Previous track", media)
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("mitishell brightness up"), "Brightness up", media)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("mitishell brightness down"), "Brightness down", media)
