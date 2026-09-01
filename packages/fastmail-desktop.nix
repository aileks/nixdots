{
  lib,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  asar,
  autoPatchelfHook,
  makeWrapper,
  electron,
  libgcc,
  vips,
}:

let
  pname = "fastmail-desktop";
  version = "1.7.0";
  src = fetchurl {
    url = "https://dl.fastmailcdn.com/desktop/production/linux/x64/com.fastmail.Fastmail-${version}.AppImage";
    hash = "sha512-d2RNpq0idNcVRXiQs4bSOdLry9vPVOKAnOVxeZEBY8ulsDziT1DEOTQz0FmA8JGl7MEws5rb20FBMXYGJw+hsw==";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontBuild = true;
  strictDeps = true;

  nativeBuildInputs = [
    asar
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    libgcc
    vips
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/opt"
    cp -r --no-preserve=mode "${appimageContents}/resources" "$out/opt/fastmail"
    asar extract "$out/opt/fastmail/app.asar" "$out/opt/fastmail/app.asar.unpacked"
    rm "$out/opt/fastmail/app.asar"

    install -Dt "$out/share/applications" "${appimageContents}/fastmail.desktop"
    substituteInPlace "$out/share/applications/fastmail.desktop" \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=fastmail %U" \
      --replace-fail "Name=com.fastmail.Fastmail" "Name=Fastmail"

    for res in 16 24 32 48 64 128 256 512 1024; do
      resdir="''${res}x''${res}"
      install -Dm644 \
        "${appimageContents}/usr/share/icons/hicolor/$resdir/apps/fastmail.png" \
        "$out/share/icons/hicolor/$resdir/apps/fastmail.png"
    done

    makeWrapper "${electron}/bin/electron" "$out/bin/fastmail" \
      --add-flags "$out/opt/fastmail/app.asar.unpacked" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
    runHook postInstall
  '';

  preFixup = ''
    rm -rf "$out/opt/fastmail/app.asar.unpacked/node_modules/@img/"{sharp-linuxmusl-x64,sharp-libvips-linuxmusl-x64}
  '';

  meta = {
    description = "Dedicated desktop app for Fastmail";
    homepage = "https://www.fastmail.com/blog/desktop-app/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "fastmail";
    platforms = [ "x86_64-linux" ];
  };
}
