# NixOS dotfiles

NixOS 26.05 and Home Manager configuration (with flakes)!

## Install

```bash
git clone --recurse-submodules https://github.com/aileks/nixdots.git ~/.dotfiles
cd ~/.dotfiles
sudo ./bin/install --check-only
sudo ./bin/install --hostname your-hostname
```

## Keybinds

> [!NOTE]  
> `Mod` is the Super key.

### Apps and tools

| Keys              | Action                                 |
| ----------------- | -------------------------------------- |
| `Mod + Space`     | dmenu                                  |
| `Mod + Return`    | terminal (st)                          |
| `Mod + W`         | browser (Zen)                          |
| `Mod + E`         | file manager (Thunar)                  |
| `Mod + S`         | Signal                                 |
| `Mod + M`         | Fastmail                               |
| `Mod + V`         | clipboard history (clipmenu)           |
| `Mod + ;`         | emoji picker (bemoji)                  |
| `Mod + O`         | pick a screen color into the clipboard |
| `Mod + Shift + P` | power menu                             |

### Capture

| Keys                  | Action                                                    |
| --------------------- | --------------------------------------------------------- |
| `Print`               | screenshot region                                         |
| `Ctrl + Print`        | screenshot focused window                                 |
| `Shift + Print`       | screenshot full screen                                    |
| `Mod + Print`         | record screen region (press again to stop)                |
| `Mod + Shift + Print` | record the monitor under the cursor (press again to stop) |
| `Mod + R`             | recording menu (region or screen, audio choice)           |

Screenshots land in `~/Pictures/Screenshots`, recordings in `~/Videos/Recordings`.

### Session

| Keys                     | Action                        |
| ------------------------ | ----------------------------- |
| `Mod + Escape`           | lock session                  |
| `Mod + N`                | toggle do not disturb (dunst) |
| `Mod + Ctrl + N`         | toggle night light            |
| `Mod + Shift + R`        | restart dwm                   |
| `Mod + Ctrl + Shift + Q` | restart dwm                   |

### Windows

| Keys                                        | Action                                |
| ------------------------------------------- | ------------------------------------- |
| `Mod + Q`                                   | close window                          |
| `Mod + F`                                   | toggle fullscreen                     |
| `Mod + Shift + Return`                      | move window to master                 |
| `Mod + I` / `Mod + Shift + I`               | add or remove a master slot           |
| `Mod + Shift + F`                           | monocle layout                        |
| `Mod + Ctrl + J` / `Mod + Ctrl + K`         | grow or shrink a window (cfact patch) |
| `Mod + Ctrl + Return`                       | reset window sizes                    |
| `Mod + Ctrl + G` / `Mod + Ctrl + Shift + G` | toggle or reset gaps                  |

### Media and brightness

| Keys                         | Action                                |
| ---------------------------- | ------------------------------------- |
| `Volume Up / Down / Mute`    | output volume                         |
| `Mic Mute`                   | microphone mute                       |
| `Play / Pause / Next / Prev` | media player control (playerctl)      |
| `Brightness Up / Down`       | external monitor brightness (ddcutil) |
