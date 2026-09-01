{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  papirus-icon-theme,
  bash,
  coreutils,
  findutils,
  gawk,
  getent,
  gnugrep,
  gnused,
  gtk3,
}:

stdenvNoCC.mkDerivation {
  pname = "papirus-cinder-grove";
  version = "2026-08-26";

  src = fetchFromGitHub {
    owner = "aileks";
    repo = "papirus-folders";
    rev = "e76cc8b2a7e3139c500622dac2c9653042cfccb5";
    hash = "sha256-epd2k4fOe/woogmqJsC23yrp6BMTr8eUFIvxuYR+PEQ=";
  };

  nativeBuildInputs = [
    bash
    coreutils
    findutils
    gawk
    getent
    gnugrep
    gnused
    gtk3
  ];
  dontBuild = true;
  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/icons"
    cp -a ${papirus-icon-theme}/share/icons/. "$out/share/icons/"
    chmod -R u+w "$out/share/icons"

    export HOME="$TMPDIR/home"
    export XDG_DATA_DIRS="$out/share"
    mkdir -p "$HOME"
    ${bash}/bin/bash ./papirus-folders-cg --once --theme Papirus-Dark --color grove

    for theme in Papirus Papirus-Dark Papirus-Light; do
      ${gtk3}/bin/gtk-update-icon-cache -f "$out/share/icons/$theme"
    done

    install -Dm644 LICENSE "$out/share/licenses/papirus-cinder-grove/LICENSE"
    runHook postInstall
  '';

  meta = {
    description = "Papirus icon themes with Cinder Grove folders";
    homepage = "https://github.com/aileks/papirus-folders";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
