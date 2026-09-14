{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarn,
  nodejs_22,
  python3,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sql-language-server";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "joe-re";
    repo = "sql-language-server";
    rev = "ea2bcadc6fca8e464e1d6bbbca45fbd30939ffec";
    hash = "sha256-rPv8z6EXSQ8GLFK98a1LAUVPQQ9uDxHOYJsAKrMJp6Q=";
  };
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-qB4MgMxPVjtJzWJ1nsgqvFSeti5GHm4+W2rIjmI01dI=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarn
    nodejs_22
    python3
    makeWrapper
  ];

  env = {
    npm_config_nodedir = nodejs_22;
    npm_config_build_from_source = "true";
    npm_config_offline = "true";
  };

  buildPhase = ''
    runHook preBuild
    npm rebuild sqlite3 --build-from-source --offline
    yarn --offline workspace @joe-re/sql-parser build
    yarn --offline build:sqlint
    yarn --offline build:server
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/sql-language-server" "$out/bin"
    cp -R node_modules packages example "$out/lib/sql-language-server/"
    makeWrapper ${nodejs_22}/bin/node "$out/bin/sql-language-server" \
      --add-flags "$out/lib/sql-language-server/packages/server/npm_bin/cli.js"
    runHook postInstall
  '';

  meta = {
    description = "SQL language server";
    homepage = "https://github.com/joe-re/sql-language-server";
    license = lib.licenses.mit;
    mainProgram = "sql-language-server";
    platforms = lib.platforms.linux;
  };
})
