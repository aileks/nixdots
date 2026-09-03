{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  xcbutil,
}:
stdenv.mkDerivation {
  pname = "dwmblocks-async";
  version = "unstable-2026-04-18";

  src = fetchFromGitHub {
    owner = "UtkarshVerma";
    repo = "dwmblocks-async";
    rev = "469e6841432693d81a17088706d99ef044a29936";
    hash = "sha256-gACpUAFVT/6Z9IvWQQ+IW7vNG7kzgJeVkXXMJeuw1V0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ xcbutil ];

  postPatch = ''
    cp ${../dwmblocks/config.h} config.h
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta.mainProgram = "dwmblocks";
}
