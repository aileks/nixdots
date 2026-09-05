# VoxType overlay focus

VoxType's GTK4 overlay uses Wayland layer-shell to request no keyboard input.
On X11 those calls fail and the overlay becomes a normal managed window. A
dwm rule matches its observed `WM_CLASS`, `voxtype-osd-gtk4`, and sets
`canfocus = 0`, `isfloating = 1`, and `noswallow = 1`.

The [upstream canfocusrule patch][canfocus] is fetched unchanged. The local
fixup integrates its declarations with the other patches and completes the
focus handling:

- Initialize all clients, including transient dialogs, as focusable.
- Preserve selection when excluded windows appear, and skip them during
  fallback selection, keyboard cycling, pointer entry, and clicks.
- Suppress both direct focus and `WM_TAKE_FOCUS` requests to excluded clients.
- Raise visible, non-focusable floating windows after normal stacking,
  including fullscreen transitions. This is the rule's overlay behavior.

`neverfocus` alone does not provide this behavior. [dwm][dwm] updates that field
from `WM_HINTS` and still sends `WM_TAKE_FOCUS`. GTK4's [X11 event handler][gtk]
responds to that protocol by setting input focus.

Run the isolated regression test with:

```sh
nix build .#checks.x86_64-linux.dwmFocus --no-link --print-build-logs
```

It starts a private Xvfb server and the packaged dwm, checks X input focus and
the active-window property, and verifies typed characters reach the original
window. It covers remapping, focus cycling, pointer interaction, application
focus requests, floating/fullscreen targets, transient dialogs, and the last
ordinary window closing. It does not exercise microphone capture or F9.

Activation requires a NixOS rebuild and replacement of the running dwm. Keep
VoxType OSD disabled until the new dwm is active; then enable it declaratively,
restart VoxType, and verify actual F9 press/release dictation on both monitors.
Layer-shell warnings may remain on X11; this patch does not implement Wayland
overlay placement or change VoxType itself.

[canfocus]: https://dwm.suckless.org/patches/canfocusrule/dwm-canfocusrule-20200702-f709b19.diff
[dwm]: https://git.suckless.org/dwm/file/dwm.c.html
[gtk]: https://github.com/GNOME/gtk/blob/gtk-4-20/gdk/x11/gdkdisplay-x11.c
