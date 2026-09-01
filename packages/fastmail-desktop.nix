{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "fastmail-desktop";
  version = "1.7.0";
  src = fetchurl {
    url = "https://dl.fastmailcdn.com/desktop/production/linux/x64/com.fastmail.Fastmail-${version}.AppImage";
    hash = "sha512-d2RNpq0idNcVRXiQs4bSOdLry9vPVOKAnOVxeZEBY8ulsDziT1DEOTQz0FmA8JGl7MEws5rb20FBMXYGJw+hsw==";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [
    pkgs.libsecret
    pkgs.xdg-utils
  ];

  extraInstallCommands = ''
    install -Dm444 "${appimageContents}/fastmail.desktop" "$out/share/applications/fastmail.desktop"
    substituteInPlace "$out/share/applications/fastmail.desktop" \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=fastmail %U" \
      --replace-fail "Name=com.fastmail.Fastmail" "Name=Fastmail"

    for res in 16 24 32 48 64 128 256 512 1024; do
      resdir="''${res}x''${res}"
      install -Dm444 \
        "${appimageContents}/usr/share/icons/hicolor/$resdir/apps/fastmail.png" \
        "$out/share/icons/hicolor/$resdir/apps/fastmail.png"
    done

    mv "$out/bin/${pname}" "$out/bin/fastmail"
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
