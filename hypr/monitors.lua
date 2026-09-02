local main = "DP-4"
local side = "HDMI-A-2"

-- Keep an unknown connector usable until the named layout is edited.
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1 })

hl.monitor({
	output = side,
	mode = "1920x1080@200.0",
	position = "0x0",
	scale = 1,
	transform = 1,
})

hl.monitor({
	output = main,
	mode = "2560x1440@200.0",
	position = "1080x200",
	scale = 1,
})

for workspace = 1, 7 do
	hl.workspace_rule({
		workspace = tostring(workspace),
		monitor = main,
		persistent = true,
		default = workspace == 1,
	})
end

hl.workspace_rule({
	workspace = "8",
	monitor = side,
	persistent = true,
	default = true,
})
