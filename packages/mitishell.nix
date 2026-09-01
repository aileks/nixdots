{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mitishell";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "aileks";
    repo = "mitishell";
    rev = "32a3efdde82cf8e3b0c23634fefe709a8eeaea58";
    hash = "sha256-L2o5sVDwMSGFhmn7bTYucm4OMhsxEV9ifAxFjj5i3Xo=";
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
    license = lib.licenses.mit;
    mainProgram = "mitishell";
    platforms = lib.platforms.linux;
  };
}
