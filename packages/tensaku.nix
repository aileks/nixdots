{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  libepoxy,
  fontconfig,
  libxkbcommon,
  libGL,
}:

rustPlatform.buildRustPackage rec {
  pname = "tensaku";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "jondkinney";
    repo = "tensaku";
    rev = "996f5f97d2f9b84ec530eb57577a3de315788037";
    hash = "sha256-rkLDfzGFonNghDspDDH6sLikOC/5TZtUCvIPHWtdLXI=";
  };

  cargoHash = "sha256-eFG6MhSnoPzwSX8FkK+qFOSCFsCJay8jiFAMeXgNrds=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    libadwaita
    libepoxy
    fontconfig
    libxkbcommon
    libGL
  ];
  buildFeatures = [ "ci-release" ];

  postInstall = ''
    install -Dm755 assets/tensaku-edit "$out/bin/tensaku-edit"
    install -Dm755 assets/tensaku-capture "$out/bin/tensaku-capture"
    install -Dm644 dev.tensaku.Tensaku.desktop "$out/share/applications/dev.tensaku.Tensaku.desktop"
    install -Dm644 assets/tensaku.svg "$out/share/icons/hicolor/scalable/apps/dev.tensaku.Tensaku.svg"
    install -Dm644 man/tensaku.1 "$out/share/man/man1/tensaku.1"
    install -Dm644 completions/tensaku.bash "$out/share/bash-completion/completions/tensaku"
    install -Dm644 completions/tensaku.fish "$out/share/fish/vendor_completions.d/tensaku.fish"
    install -Dm644 completions/_tensaku "$out/share/zsh/site-functions/_tensaku"
    install -Dm644 LICENSE "$out/share/licenses/${pname}/LICENSE"
    install -Dm644 NOTICE "$out/share/licenses/${pname}/NOTICE"
  '';

  meta = {
    description = "Modern screenshot annotation tool for Wayland";
    homepage = "https://github.com/jondkinney/tensaku";
    license = lib.licenses.mpl20;
    mainProgram = "tensaku";
    platforms = lib.platforms.linux;
  };
}
