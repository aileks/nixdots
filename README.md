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

| Keys                 | Action                       |
| -------------------- | ---------------------------- |
| `Mod + Space`        | dmenu                        |
| `Mod + Ctrl + Space` | desktop actions menu         |
| `Mod + Return`       | terminal (st)                |
| `Mod + T`            | tmux project launcher        |
| `Mod + W`            | browser (Zen)                |
| `Mod + E`            | file manager (Thunar)        |
| `Mod + S`            | Signal                       |
| `Mod + A`            | audio mixer (Wiremix)        |
| `Mod + M`            | Fastmail                     |
| `Mod + V`            | clipboard history (clipmenu) |
| `Mod + ;`            | emoji picker (bemoji)        |
| `Mod + O`            | color picker                 |
| `Mod + Ctrl + R`     | reminders dmenu script       |
| `Mod + =`            | quick dmenu calculations     |
| `Mod + Shift + P`    | power menu                   |

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
| `Mod + Shift + R`        | restart dwm                   |

### Windows

| Keys                                | Action                                |
| ----------------------------------- | ------------------------------------- |
| `Mod + Q`                           | close window                          |
| `Mod + F`                           | toggle fullscreen                     |
| `Mod + Shift + Return`              | move window to master                 |
| `Mod + I` / `Mod + Shift + I`       | add or remove a master slot           |
| `Mod + Ctrl + J` / `Mod + Ctrl + K` | grow or shrink a window (cfact patch) |
| `Mod + H` / `Mod + L`               | grow or shrink master horizontally    |
| `Mod + Ctrl + Return`               | reset window sizes                    |

### Media and brightness

| Keys                         | Action                                |
| ---------------------------- | ------------------------------------- |
| `Volume Up / Down / Mute`    | output volume                         |
| `Mic Mute`                   | microphone mute                       |
| `Play / Pause / Next / Prev` | media player control (playerctl)      |
| `Brightness Up / Down`       | external monitor brightness (ddcutil) |
