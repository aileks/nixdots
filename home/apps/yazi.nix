{ ... }:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  xdg.configFile."yazi/cinder-grove.tmTheme".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>name</key><string>Cinder Grove</string>
      <key>settings</key>
      <array>
        <dict>
          <key>settings</key>
          <dict>
            <key>background</key><string>${colors.background}</string>
            <key>foreground</key><string>${colors.text}</string>
            <key>caret</key><string>${colors.bright}</string>
            <key>selection</key><string>${colors.visual}</string>
            <key>lineHighlight</key><string>${colors.surface}</string>
          </dict>
        </dict>
        <dict>
          <key>scope</key><string>comment</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.muted}</string><key>fontStyle</key><string>italic</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>string</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.green}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>constant, keyword, storage.modifier</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.orange}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>keyword.operator</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.cyan}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>entity.name.function, support.function</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.blue}</string><key>fontStyle</key><string>bold</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>entity.name.type, entity.name.class, support.type, support.class, storage.type</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.yellow}</string><key>fontStyle</key><string>italic</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>meta.preprocessor, keyword.control.import, keyword.control.include, entity.name.label</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.purple}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>constant.character.escape</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.yellow}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>entity.name.tag</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.blue}</string><key>fontStyle</key><string>italic</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>punctuation.separator, punctuation.terminator</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.muted}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>markup.heading</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.orange}</string><key>fontStyle</key><string>bold</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>markup.inserted</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.green}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>markup.deleted, invalid</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.red}</string></dict>
        </dict>
        <dict>
          <key>scope</key><string>markup.changed</string>
          <key>settings</key>
          <dict><key>foreground</key><string>${colors.yellow}</string></dict>
        </dict>
      </array>
    </dict>
    </plist>
  '';
}
