{ pkgs }:
pkgs.symlinkJoin {
  name = "postgresql-client";
  paths = [ pkgs.postgresql_18 ];
  postBuild = ''
    rm "$out/bin/psql"
    ln -s ${pkgs.postgresql_18}/bin/psql "$out/bin/psql-native"
  '';
}
