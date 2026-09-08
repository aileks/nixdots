local act = wezterm.action
local mux = wezterm.mux
local previous_workspace

local function workspace_exists(name)
  for _, workspace in ipairs(mux.get_workspace_names()) do
    if workspace == name then
      return true
    end
  end
  return false
end

local function switch_workspace(window, pane, selection)
  local name = selection.workspace
  mux.get_domain('unix'):attach()
  if not selection.can_create and not workspace_exists(name) then
    window:toast_notification('wezterm', 'Workspace no longer exists: ' .. name, nil, 3000)
    return
  end
  local current = mux.get_active_workspace()
  if name == current then
    return
  end
  window:perform_action(act.SwitchToWorkspace {
    name = name,
    spawn = { cwd = selection.cwd, domain = { DomainName = 'unix' } },
  }, pane)
  previous_workspace = current
end

local function choose_workspace(window, pane)
  mux.get_domain('unix'):attach()
  local choices = {}
  for _, name in ipairs(mux.get_workspace_names()) do
    table.insert(choices, { id = name, label = name })
  end
  table.sort(choices, function(a, b) return a.id < b.id end)
  window:perform_action(act.InputSelector {
    title = 'Workspaces',
    fuzzy = true,
    choices = choices,
    action = wezterm.action_callback(function(win, active_pane, name)
      if name then
        switch_workspace(win, active_pane, { workspace = name })
      end
    end),
  }, pane)
end

local function choose_project(window, pane)
  local ok, stdout = wezterm.run_child_process { 'wezterm-dmenu', '--select-only' }
  if not ok then
    window:toast_notification('wezterm', 'Could not open workspace picker', nil, 3000)
    return
  end
  if stdout == '' then
    return
  end
  local selection = wezterm.json_parse(stdout)
  switch_workspace(window, pane, selection)
end

config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'Space', mods = 'LEADER|CTRL', action = act.SendKey { key = 'Space', mods = 'CTRL' } },
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'Space', mods = 'LEADER', action = act.ActivateLastTab },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 's', mods = 'LEADER', action = wezterm.action_callback(choose_workspace) },
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|TABS' } },
  { key = 'o', mods = 'LEADER', action = wezterm.action_callback(choose_project) },
  { key = '^', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
    if previous_workspace and workspace_exists(previous_workspace) then
      switch_workspace(window, pane, { workspace = previous_workspace })
    end
  end) },
  -- Closing a window kills its panes. Detach explicitly to preserve them.
  { key = 'd', mods = 'LEADER', action = act.DetachDomain 'CurrentPaneDomain' },
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
}

for number = 1, 9 do
  table.insert(config.keys, { key = tostring(number), mods = 'LEADER', action = act.ActivateTab(number - 1) })
end

wezterm.on('update-right-status', function(window)
  window:set_right_status(window:active_workspace())
end)
