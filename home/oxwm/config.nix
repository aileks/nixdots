{ config, pkgs }:
let
  lib = pkgs.lib;
  colors = import ../../theme/cinder-grove.nix;
  scripts = config.lib.nixdots.scripts;
  lua = lib.generators.toLua { };
  expression = lib.generators.mkLuaInline;
  terminal = "${config.programs.wezterm.package}/bin/wezterm";
  spawn = modifiers: key: argv: {
    inherit modifiers key;
    action = expression "oxwm.spawn(${lua argv})";
  };
  action = modifiers: key: value: {
    inherit modifiers key;
    action = expression value;
  };
  mod = [ "Mod4" ];
  shift = mod ++ [ "Shift" ];
  ctrl = mod ++ [ "Control" ];
  bindings = [
    (spawn mod "Return" [
      terminal
      "connect"
      "unix"
    ])
    (spawn mod "Space" [
      "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop"
      "--dmenu=${pkgs.dmenu}/bin/dmenu -i"
    ])
    (spawn mod "T" [ "${scripts.wezterm-sessions}/bin/wezterm-sessions" ])
    (spawn mod "W" [ "${config.lib.nixdots.zenBrowser}/bin/zen-beta" ])
    (spawn mod "X" [
      "${config.programs.doom-emacs.finalEmacsPackage}/bin/emacsclient"
      "--create-frame"
      "--alternate-editor=${config.programs.doom-emacs.finalEmacsPackage}/bin/emacs"
    ])
    (spawn mod "E" [
      terminal
      "start"
      "--always-new-process"
      "--"
      "${config.programs.yazi.finalPackage}/bin/yazi"
    ])
    (spawn mod "S" [ "${pkgs.signal-desktop}/bin/signal-desktop" ])
    (spawn mod "A" [
      terminal
      "start"
      "--always-new-process"
      "--"
      "${pkgs.wiremix}/bin/wiremix"
    ])
    (spawn mod "M" [
      "${config.lib.nixdots.zenBrowser}/bin/zen-beta"
      "https://app.fastmail.com/"
    ])
    (spawn mod "O" [ "${scripts.color-picker}/bin/color-picker" ])
    (spawn mod "V" [ "${scripts.clipboard-menu}/bin/clipboard-menu" ])
    (spawn mod "Semicolon" [
      "${pkgs.bemoji}/bin/bemoji"
      "-n"
    ])
    (spawn mod "Escape" [
      "${pkgs.systemd}/bin/loginctl"
      "lock-session"
    ])
    (spawn mod "N" [ "${scripts.dnd-toggle}/bin/dnd-toggle" ])
    (spawn ctrl "N" [ "${scripts.night-light}/bin/night-light" ])
    (spawn shift "P" [ "${scripts.power-menu}/bin/power-menu" ])
    (spawn mod "R" [
      "${scripts.screenrecord}/bin/screenrecord"
      "menu"
    ])
    (spawn [ ] "Print" [
      "${scripts.screenshot}/bin/screenshot"
      "region"
    ])
    (spawn [ "Control" ] "Print" [
      "${scripts.screenshot}/bin/screenshot"
      "window"
    ])
    (spawn [ "Shift" ] "Print" [
      "${scripts.screenshot}/bin/screenshot"
      "full"
    ])
    (spawn mod "Print" [
      "${scripts.screenrecord}/bin/screenrecord"
      "region"
    ])
    (spawn shift "Print" [
      "${scripts.screenrecord}/bin/screenrecord"
      "output"
    ])
    (spawn ctrl "Space" [ "${scripts.desktop-actions}/bin/desktop-actions" ])
    (spawn shift "O" [ "${scripts.region-ocr}/bin/region-ocr" ])
    (spawn ctrl "O" [ "${scripts.qr-scan}/bin/qr-scan" ])
    (spawn ctrl "R" [ "${scripts.reminder}/bin/reminder" ])
    (spawn mod "Equal" [ "${scripts.calculate}/bin/calculate" ])
    (spawn shift "N" [ "${scripts.notification-history}/bin/notification-history" ])
    (spawn (ctrl ++ [ "Shift" ]) "N" [
      "${pkgs.dunst}/bin/dunstctl"
      "context"
    ])
    (action mod "Q" "oxwm.client.kill()")
    (action mod "F" "oxwm.client.toggle_fullscreen()")
    (action shift "Space" "oxwm.client.toggle_floating()")
    (action mod "J" "oxwm.client.focus_stack(1)")
    (action mod "K" "oxwm.client.focus_stack(-1)")
    (action shift "J" "oxwm.client.move_stack(1)")
    (action shift "K" "oxwm.client.move_stack(-1)")
    (action ctrl "H" "oxwm.set_master_factor(-50)")
    (action ctrl "L" "oxwm.set_master_factor(50)")
    (action mod "I" "oxwm.inc_num_master(1)")
    (action shift "I" "oxwm.inc_num_master(-1)")
    (action mod "Tab" "oxwm.tag.view_previous()")
    (action mod "Comma" "oxwm.monitor.focus(-1)")
    (action mod "Period" "oxwm.monitor.focus(1)")
    (action shift "Comma" "oxwm.monitor.tag(-1)")
    (action shift "Period" "oxwm.monitor.tag(1)")
    (action shift "Q" "oxwm.quit()")
    (action shift "R" "oxwm.restart()")
    (action mod "B" "oxwm.toggle_bar()")
    (action mod "C" "oxwm.layout.set(\"tiling\")")
    (action shift "C" "oxwm.layout.set(\"monocle\")")
  ]
  ++ lib.concatMap (
    tag:
    map
      (
        binding: action binding.modifiers (toString tag) "oxwm.tag.${binding.method}(${toString (tag - 1)})"
      )
      [
        {
          modifiers = mod;
          method = "view";
        }
        {
          modifiers = shift;
          method = "move_to";
        }
        {
          modifiers = ctrl;
          method = "toggleview";
        }
        {
          modifiers = ctrl ++ [ "Shift" ];
          method = "toggletag";
        }
      ]
  ) (lib.range 1 7)
  ++ map (binding: spawn [ ] binding.key binding.argv) [
    {
      key = "XF86AudioRaiseVolume";
      argv = [
        "${scripts.audio}/bin/audio"
        "sink"
        "up"
      ];
    }
    {
      key = "XF86AudioLowerVolume";
      argv = [
        "${scripts.audio}/bin/audio"
        "sink"
        "down"
      ];
    }
    {
      key = "XF86AudioMute";
      argv = [
        "${scripts.audio}/bin/audio"
        "sink"
        "mute"
      ];
    }
    {
      key = "XF86AudioMicMute";
      argv = [
        "${scripts.audio}/bin/audio"
        "mic"
        "mute"
      ];
    }
    {
      key = "XF86MonBrightnessUp";
      argv = [
        "${scripts.brightness}/bin/brightness"
        "up"
      ];
    }
    {
      key = "XF86MonBrightnessDown";
      argv = [
        "${scripts.brightness}/bin/brightness"
        "down"
      ];
    }
    {
      key = "XF86AudioPlay";
      argv = [
        "${pkgs.playerctl}/bin/playerctl"
        "play-pause"
      ];
    }
    {
      key = "XF86AudioPause";
      argv = [
        "${pkgs.playerctl}/bin/playerctl"
        "play-pause"
      ];
    }
    {
      key = "XF86AudioNext";
      argv = [
        "${pkgs.playerctl}/bin/playerctl"
        "next"
      ];
    }
    {
      key = "XF86AudioPrev";
      argv = [
        "${pkgs.playerctl}/bin/playerctl"
        "previous"
      ];
    }
  ];
  block =
    name: interval: color: click:
    expression "oxwm.bar.block.shell(${
      lua {
        command = "${scripts.${name}}/bin/${name}";
        format = "{}";
        inherit interval color click;
        underline = false;
      }
    })";
  separator = expression "oxwm.bar.block.static(${
    lua {
      text = "│";
      color = colors.muted;
    }
  })";
  blocks = [
    (expression "oxwm.bar.block.systray({})")
  ]
  ++ lib.intersperse separator [
    (block "bar-dnd" 1 colors.orange "${scripts.notification-history}/bin/notification-history")
    (block "bar-network" 5 colors.cyan
      "${terminal} start --always-new-process -- ${pkgs.networkmanager}/bin/nmtui"
    )
    (block "bar-volume" 1 colors.purple "${scripts.audio}/bin/audio sink mute")
    (block "bar-cpu-temperature" 10 colors.blue
      "${terminal} start --always-new-process -- ${config.programs.btop.package}/bin/btop"
    )
    (block "bar-memory" 10 colors.green
      "${terminal} start --always-new-process -- ${config.programs.btop.package}/bin/btop"
    )
    (block "bar-gpu" 5 colors.purple
      "${terminal} start --always-new-process -- ${pkgs.nvtopPackages.nvidia}/bin/nvtop"
    )
    (block "bar-clock" 1 colors.bright
      "${pkgs.coreutils}/bin/env BLOCK_BUTTON=1 ${scripts.bar-clock}/bin/bar-clock"
    )
  ];
in
''
  oxwm.set_terminal(${lua terminal})
  oxwm.set_modkey("Mod4")
  oxwm.set_tags(${lua (map toString (lib.range 1 7))})
  oxwm.set_layout("tiling")
  oxwm.border.set_width(2)
  oxwm.border.set_focused_color(${lua colors.orange})
  oxwm.border.set_unfocused_color(${lua colors.muted})
  oxwm.gaps.set_smart(false)
  oxwm.gaps.set_inner(4, 4)
  oxwm.gaps.set_outer(4, 4)
  oxwm.bar.set_font("Iosevka Nerd Font:size=11")
  oxwm.bar.set_blocks(${lua blocks})
  oxwm.bar.set_scheme_normal(${lua colors.text}, ${lua colors.background}, ${lua colors.muted})
  oxwm.bar.set_scheme_occupied(${lua colors.bright}, ${lua colors.background}, ${lua colors.orange})
  oxwm.bar.set_scheme_selected(${lua colors.background}, ${lua colors.orange}, ${lua colors.orange})
  oxwm.bar.set_scheme_urgent(${lua colors.bright}, ${lua colors.red}, ${lua colors.red})
  ${lib.concatMapStringsSep "\n"
    (
      class:
      "oxwm.rule.add(${
        lua {
          inherit class;
          floating = true;
        }
      })"
    )
    [
      "imv"
      "Qalculate-gtk"
      "Blueman-manager"
      "Bitwarden"
      "localsend_app"
      "Nm-connection-editor"
      "Polkit-gnome-authentication-agent-1"
    ]
  }
  ${lib.concatMapStringsSep "\n" (
    binding: "oxwm.key.bind(${lua binding.modifiers}, ${lua binding.key}, ${lua binding.action})"
  ) bindings}
''
