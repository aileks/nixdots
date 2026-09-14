{ pkgs, monitors }:
let
  policy = pkgs.writeText "monitor-policy.json" (builtins.toJSON monitors);
  configure = pkgs.writeText "configure-monitors.py" ''
    import json
    import re
    import subprocess
    import sys

    policy = json.load(open(sys.argv[1]))
    properties = subprocess.check_output(["${pkgs.xrandr}/bin/xrandr", "--props"], text=True)
    outputs = {}
    current = None
    collecting_edid = False
    for line in properties.splitlines():
        match = re.match(r"^(\S+) connected\b", line)
        if match:
            current = match[1]
            outputs[current] = ""
            collecting_edid = False
        elif line and not line[0].isspace():
            current = None
        elif current and line.strip() == "EDID:":
            collecting_edid = True
        elif current and collecting_edid:
            chunk = line.strip()
            if re.fullmatch(r"[0-9a-fA-F]{32}", chunk):
                outputs[current] += chunk.lower()
            else:
                collecting_edid = False
    for name, monitor in policy.items():
        matches = [output for output, edid in outputs.items() if edid == monitor["edid"].lower()]
        if len(matches) != 1:
            print(f"Monitor {name}: no unique EDID match; retaining Xorg's detected mode", file=sys.stderr)
            continue
        command = ["${pkgs.xrandr}/bin/xrandr", "--output", matches[0], "--mode", monitor["mode"],
                   "--rate", monitor["rate"], "--pos", monitor["position"]]
        if name == "primary":
            command.append("--primary")
        result = subprocess.run(command, check=False)
        if result.returncode:
            print(f"Monitor {name}: requested mode unavailable; retaining detected mode", file=sys.stderr)
  '';
in
pkgs.writeShellApplication {
  name = "configure-monitors";
  passthru.pythonSource = configure;
  text = "exec ${pkgs.python3}/bin/python3 ${configure} ${policy}";
}
