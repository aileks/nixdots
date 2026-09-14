{
  lib,
  libxcursor,
  oxwm,
}:
oxwm.overrideAttrs (previous: {
  postFixup = (previous.postFixup or "") + ''
    patchelf --add-rpath ${lib.makeLibraryPath [ libxcursor ]} "$out/bin/oxwm"
    patchelf --add-needed libXcursor.so.1 "$out/bin/oxwm"
  '';
})
