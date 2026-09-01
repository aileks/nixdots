{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "cinder-grove-gtk";
  version = "2026-08-26";

  src = fetchFromGitHub {
    owner = "aileks";
    repo = "cinder-grove-gtk";
    rev = "a1a74295d6dcc235623a72fc024bdeff3134c5a9";
    hash = "sha256-pZWI1Fb1d7JOInS93M/3FPCPW8BZ/t0Q5hoRixtO0Qo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/themes"
    cp -r Cinder-Grove-Dark "$out/share/themes/Cinder-Grove-Dark"
    install -Dm644 LICENSE "$out/share/licenses/cinder-grove-gtk/LICENSE"
    cp -r LICENSES "$out/share/licenses/cinder-grove-gtk/LICENSES"
    runHook postInstall
  '';

  meta = {
    description = "Cinder Grove dark GTK theme";
    homepage = "https://github.com/aileks/cinder-grove-gtk";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
  };
}
