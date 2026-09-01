{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mitishell";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "aileks";
    repo = "mitishell";
    rev = "7d95e3da30e2d0e2721934571115a975994e0032";
    hash = "sha256-Ba5S8loMakR5NViSp80U6nv+3ZpJntmrkhtapAAmpRw=";
  };

  vendorHash = "sha256-Ac63bZlBvCrhS7b8mk7aJdApI8UGtJxnZG35L37roGY=";
  subPackages = [ "cmd/mitishell" ];
  ldflags = [ "-X main.version=${version}" ];

  postInstall = ''
    install -Dm644 data/mitishell.desktop "$out/share/applications/mitishell.desktop"
    mkdir -p "$out/share/mitishell"
    cp -r shell "$out/share/mitishell/shell"
    install -Dm644 LICENSE "$out/share/licenses/${pname}/LICENSE"
    install -Dm644 THIRD_PARTY_LICENSES.md "$out/share/licenses/${pname}/THIRD_PARTY_LICENSES.md"
  '';

  meta = {
    description = "Personal Hyprland desktop shell";
    homepage = "https://github.com/aileks/mitishell";
    license = lib.licenses.gpl3Plus;
    mainProgram = "mitishell";
    platforms = lib.platforms.linux;
  };
}
