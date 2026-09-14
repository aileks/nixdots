# NixOS dotfiles

NixOS unstable with Flakes and Home Manager built around [oxwm](https://github.com/tonybanters/oxwm)

## Install

Boot a NixOS live ISO in UEFI mode and prepare the storage:

| Filesystem        | Label   | Before installing      |
| ----------------- | ------- | ---------------------- |
| ext4 root         | `nixos` | Mount at `/mnt`        |
| FAT EFI partition | `boot`  | Mount at `/mnt/boot`   |
| Swap              | `swap`  | Activate with `swapon` |

Clone into the target user's home, then run the preflight and installer:

```bash
sudo mkdir -p /mnt/home/<your user>
sudo git clone https://github.com/<your user>/nixdots.git /mnt/home/<your user>/.dotfiles
cd /mnt/home/<your user>/.dotfiles

sudo nix --extra-experimental-features 'nix-command flakes' run .#install -- --hostname <your host> --check-only
sudo nix --extra-experimental-features 'nix-command flakes' run .#install -- --hostname <your host>
```

For another host, add its directory under `hosts/` and its name to `hostNames` in `flake.nix`. `hexghost` includes NVIDIA and physical monitor settings; a VM without GPU passthrough needs settings for its virtual GPU before installation. Update user in [installation.nix](installation.nix).

## Desktop shortcuts

`Mod` is Super. These bindings are defined in
[home/oxwm/config.nix](home/oxwm/config.nix).

### Launchers and applications

| Shortcut             | Action                                                                  |
| -------------------- | ----------------------------------------------------------------------- |
| `Mod + Space`        | Search applications with dmenu                                          |
| `Mod + Ctrl + Space` | Desktop actions: OCR, QR, reminders, notifications, network, calculator |
| `Mod + Return`       | Open a WezTerm mux terminal                                             |
| `Mod + T`            | Choose a terminal project or workspace                                  |
| `Mod + W`            | Open Zen                                                                |
| `Mod + X`            | Open a Doom Emacs frame                                                 |
| `Mod + E`            | Open Yazi in WezTerm                                                    |
| `Mod + S`            | Open Signal                                                             |
| `Mod + A`            | Open Wiremix                                                            |
| `Mod + M`            | Open Fastmail in Zen                                                    |
| `Mod + V`            | Choose from clipboard history with clipmenu                             |
| `Mod + ;`            | Pick an emoji                                                           |
| `Mod + O`            | Pick a color                                                            |
| `Mod + Ctrl + R`     | Manage reminders                                                        |
| `Mod + =`            | Calculate an expression                                                 |

### Windows and layouts

| Shortcut                      | Action                                          |
| ----------------------------- | ----------------------------------------------- |
| `Mod + Q`                     | Close the focused window                        |
| `Mod + F`                     | Toggle fullscreen                               |
| `Mod + Shift + Space`         | Toggle floating                                 |
| `Mod + J` / `K`               | Focus the next / previous window                |
| `Mod + Shift + J` / `K`       | Move the window forward / backward in the stack |
| `Mod + Ctrl + H` / `L`        | Shrink / grow the master area                   |
| `Mod + I` / `Mod + Shift + I` | Add / remove a master slot                      |
| `Mod + C`                     | Use the tiling layout                           |
| `Mod + Shift + C`             | Use the monocle layout                          |
| `Mod + B`                     | Show or hide the bar                            |

### Tags and monitors

| Shortcut                    | Action                                         |
| --------------------------- | ---------------------------------------------- |
| `Mod + 1..7`                | View a tag                                     |
| `Mod + Ctrl + 1..7`         | Toggle a tag's visibility                      |
| `Mod + Shift + 1..7`        | Move the focused window to a tag               |
| `Mod + Ctrl + Shift + 1..7` | Toggle the window's membership in a tag        |
| `Mod + Tab`                 | Return to the previous tag view                |
| `Mod + ,` / `.`             | Focus the previous / next monitor              |
| `Mod + Shift + ,` / `.`     | Send the window to the previous / next monitor |

### Screenshots and recording

| Shortcut              | Action                                             |
| --------------------- | -------------------------------------------------- |
| `Print`               | Select a screenshot region                         |
| `Ctrl + Print`        | Capture the focused window                         |
| `Shift + Print`       | Capture the entire desktop                         |
| `Mod + Shift + O`     | Select text with OCR and copy it                   |
| `Mod + Ctrl + O`      | Scan a QR code and copy its contents               |
| `Mod + R`             | Choose recording mode and audio, or stop recording |
| `Mod + Print`         | Record a selected region                           |
| `Mod + Shift + Print` | Record the monitor under the pointer               |

Screenshots are saved under `Pictures/Screenshots` and copied to the X11
clipboard. Recordings go under `Videos/Recordings`; both locations follow the
configured XDG user directories. Recording regions must fit within one monitor.
OCR and QR results use the ordinary clipboard and can appear in clipboard history.

### Session and notifications

| Shortcut                 | Action                             |
| ------------------------ | ---------------------------------- |
| `Mod + Esc`              | Lock the session                   |
| `Mod + Shift + P`        | Open the power menu                |
| `Mod + N`                | Toggle do not disturb              |
| `Mod + Shift + N`        | Browse notification history        |
| `Mod + Ctrl + Shift + N` | Open notification actions and URLs |
| `Mod + Ctrl + N`         | Toggle night light                 |
| `Mod + Shift + R`        | Reload oxwm configuration          |
| `Mod + Shift + Q`        | End the oxwm session               |

### Hardware keys

| Key                     | Action                                  |
| ----------------------- | --------------------------------------- |
| Volume up / down / mute | Adjust or mute the output               |
| Microphone mute         | Toggle microphone mute                  |
| Play / pause            | Toggle playback through playerctl       |
| Next / previous         | Change media track                      |
| Brightness up / down    | Adjust external monitors through DDC/CI |

### Bar controls

| Click                     | Action                                  |
| ------------------------- | --------------------------------------- |
| Notification indicator    | Open notification history               |
| Network                   | Open NetworkManager's terminal UI       |
| Volume                    | Toggle output mute                      |
| CPU temperature or memory | Open btop                               |
| GPU                       | Open nvtop                              |
| Clock                     | Switch between 12-hour and 24-hour time |

## Terminal and file manager

### WezTerm

Press `Ctrl + Space` for `Leader`, then the next key within one second.
Workspace bindings are defined in
[home/apps/wezterm-mux.nix](home/apps/wezterm-mux.nix).

| Shortcut                 | Action                                  |
| ------------------------ | --------------------------------------- |
| `Leader`, `c`            | Create a tab                            |
| `Leader`, `n` / `p`      | Select the next / previous tab          |
| `Leader`, `Space`        | Return to the last tab                  |
| `Leader`, `1..9`         | Select a numbered tab                   |
| `Leader`, `-`            | Split into top and bottom panes         |
| `Leader`, `\|`           | Split into left and right panes         |
| `Leader`, `v`            | Enter copy mode                         |
| `Leader`, `s`            | Choose an existing workspace            |
| `Leader`, `w`            | Search tabs                             |
| `Leader`, `o`            | Choose a project or workspace           |
| `Leader`, `^`            | Return to the previous workspace        |
| `Leader`, `d`            | Detach and keep the mux session running |
| `Leader`, `Ctrl + Space` | Send a literal `Ctrl + Space`           |
| `Alt + H/J/K/L`          | Focus the left/down/up/right pane       |
| `Alt + Shift + H/J/K/L`  | Resize in that direction by five cells  |

Use detach when you want to leave terminal work running. Project search roots
and always-listed repositories are configured in [home/scripts.nix](home/scripts.nix).

### Yazi

| Shortcut        | Action                                |
| --------------- | ------------------------------------- |
| `g`, `b`        | Browse bookmarks and mounted drives   |
| `D` or `Delete` | Move selected files to trash          |
| `e`             | Edit selected files in minimal Neovim |

## Configuration locations

| Path                                             | Controls                                                     |
| ------------------------------------------------ | ------------------------------------------------------------ |
| [installation.nix](installation.nix)             | Account and storage defaults                                 |
| [hosts/hexghost/](hosts/hexghost/)               | Hardware, NVIDIA, and monitor policy                         |
| [modules/xorg.nix](modules/xorg.nix)             | Xorg, Ly session registration, and keyboard mapping          |
| [home/oxwm/](home/oxwm/)                         | oxwm configuration and session startup                       |
| [home/session.nix](home/session.nix)             | Desktop services, locking, wallpaper, and clipboard          |
| [home/apps/](home/apps/)                         | Bash, editors, terminal, and other application configuration |
| [theme/cinder-grove.nix](theme/cinder-grove.nix) | Shared color palette                                         |
| [packages/scripts/](packages/scripts/)           | Packaged desktop and command-line scripts                    |
| [checks/](checks/)                               | Generated configuration, script, and X11 checks              |
