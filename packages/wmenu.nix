{
  wmenu,
  symlinkJoin,
  makeWrapper,
}:

symlinkJoin {
  name = "wmenu-cinder-grove";
  paths = [ wmenu ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    for program in wmenu wmenu-run; do
      rm "$out/bin/$program"
      makeWrapper "${wmenu}/bin/$program" "$out/bin/$program" \
        --add-flags "-f 'Iosevka Nerd Font 16' -l 8 -N '#131210ee' -n '#BBB3A9' -M '#D9A441ee' -m '#131210' -S '#D9A441ee' -s '#131210'"
    done
  '';
  inherit (wmenu) meta;
}
