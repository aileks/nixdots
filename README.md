# NixOS dotfiles

NixOS (unstable) setup with Home Manager and Flakes.

## Install

Boot a NixOS live ISO in UEFI mode. Prepare an ext4 root filesystem labeled
`nixos`, a FAT EFI filesystem labeled `boot`, and swap labeled `swap`. Mount root
at `/mnt`, mount the EFI filesystem at `/mnt/boot`, and activate swap before
running the installer.

The declared host is `hexghost`. Add a host configuration and flake entry before
installing another host.

```bash
sudo mkdir -p /mnt/home/<your user>
sudo git clone --recurse-submodules https://github.com/aileks/nixdots.git /mnt/home/<your user>/.dotfiles
cd /mnt/home/<your user>/.dotfiles
sudo ./bin/install --hostname your-hostname --check-only
sudo ./bin/install --hostname your-hostname
```

## Rebuild

On the installed system, apply configuration changes with:

```bash
sudo nixos-rebuild switch --flake "$HOME/.dotfiles#your-hostname"
```

## Keybinds

> [!NOTE]  
> `Mod` is the Super key.

### Apps and tools

| Keys                 | Action                         |
| -------------------- | ------------------------------ |
| `Mod + Space`        | application menu (wmenu)       |
| `Mod + Ctrl + Space` | desktop actions menu           |
| `Mod + Return`       | WezTerm mux terminal           |
| `Mod + T`            | WezTerm project/workspace menu |
| `Mod + W`            | browser (Zen)                  |
| `Mod + E`            | file manager (Yazi in WezTerm) |
| `Mod + S`            | Signal                         |
| `Mod + A`            | audio mixer (Wiremix)          |
| `Mod + M`            | Fastmail                       |
| `Mod + V`            | clipboard history (cliphist)   |
| `Mod + ;`            | emoji picker (bemoji)          |
| `Mod + O`            | color picker                   |
| `Mod + Ctrl + R`     | reminders menu                 |
| `Mod + =`            | quick calculate                |
| `Mod + Shift + P`    | power menu                     |

### Capture

| Keys                  | Action                     |
| --------------------- | -------------------------- |
| `Print`               | screenshot region          |
| `Ctrl + Print`        | screenshot focused window  |
| `Shift + Print`       | screenshot full screen     |
| `Mod + Shift + O`     | OCR scan + copy            |
| `Mod + Ctrl + O`      | QR code scan + copy        |
| `Mod + R`             | recording menu             |
| `Mod + Print`         | record screen region       |
| `Mod + Shift + Print` | record the focused monitor |

### Session

| Keys                     | Action                        |
| ------------------------ | ----------------------------- |
| `Mod + Esc`              | lock session                  |
| `Mod + N`                | toggle do not disturb (dunst) |
| `Mod + Shift + N`        | notification history          |
| `Mod + Ctrl + Shift + N` | notification actions and URLs |
| `Mod + Ctrl + N`         | toggle night light            |
| `Mod + Shift + R`        | reload Mango configuration    |
| `Mod + Shift + Q`        | quit Mango                    |

### Windows

| Keys                                  | Action                                 |
| ------------------------------------- | -------------------------------------- |
| `Mod + Q`                             | close window                           |
| `Mod + F`                             | toggle fullscreen                      |
| `Mod + Shift + Space`                 | toggle floating                        |
| `Mod + J` / `Mod + K`                 | focus next or previous window          |
| `Mod + Shift + J` / `Mod + Shift + K` | exchange with next or previous window  |
| `Mod + Shift + Return`                | move window to master                  |
| `Mod + I` / `Mod + Shift + I`         | add or remove a master slot            |
| `Mod + Ctrl + J` / `Mod + Ctrl + K`   | increase or decrease window height     |
| `Mod + H` / `Mod + L`                 | shrink or grow master horizontally     |
| `Mod + Ctrl + Return`                 | reset focused tiled window proportions |
| `Mod + Backtick`                      | toggle scratchpad                      |
| `Mod + Shift + Backtick`              | minimize window                        |
| `Mod + Ctrl + Backtick`               | restore a minimized window             |
| `Mod + Left drag`                     | move window                            |
| `Mod + Right drag`                    | resize window                          |
| `Mod + Middle click`                  | toggle floating                        |
| `Mod + Scroll up/down`                | focus previous or next window          |

### Tags and monitors

| Keys                                  | Action                               |
| ------------------------------------- | ------------------------------------ |
| `Mod + 1..8`                          | view tag                             |
| `Mod + Ctrl + 1..8`                   | toggle tag visibility                |
| `Mod + Shift + 1..8`                  | move window to tag                   |
| `Mod + Ctrl + Shift + 1..8`           | toggle window membership of tag      |
| `Mod + Tab`                           | return to previous tag view          |
| `Mod + ,` / `Mod + .`                 | focus left or right monitor          |
| `Mod + Shift + ,` / `Mod + Shift + .` | send window to left or right monitor |
| `Mod + Ctrl + M`                      | monitor menu                         |

### Media and brightness

| Keys                         | Action                                |
| ---------------------------- | ------------------------------------- |
| `Volume Up / Down / Mute`    | output volume                         |
| `Mic Mute`                   | microphone mute                       |
| `Play / Pause / Next / Prev` | media player control (playerctl)      |
| `Brightness Up / Down`       | external monitor brightness (ddcutil) |

### WezTerm

`Leader` is `Ctrl + Space

| Keys                    | Action                                    |
| ----------------------- | ----------------------------------------- |
| `Leader`, `c`           | new tab                                   |
| `Leader`, `n` / `p`     | next or previous tab                      |
| `Leader`, `Space`       | return to last tab                        |
| `Leader`, `1..9`        | select tab                                |
| `Leader`, `-`           | split into top and bottom panes           |
| `Leader`, `\|`          | split into left and right panes           |
| `Leader`, `v`           | enter copy mode                           |
| `Leader`, `s`           | choose an existing workspace              |
| `Leader`, `w`           | fuzzy tab picker                          |
| `Leader`, `o`           | project/workspace menu                    |
| `Leader`, `^`           | return to previous workspace              |
| `Leader`, `d`           | detach from the current domain            |
| `Alt + H/J/K/L`         | focus left/down/up/right pane             |
| `Alt + Shift + H/J/K/L` | resize pane left/down/up/right by 5 cells |

### Yazi

| Keys            | Action                            |
| --------------- | --------------------------------- |
| `g, b`          | open bookmarks and mounted drives |
| `D` or `Delete` | trash selected files              |
| `e`             | edit selected files in Neovim     |
