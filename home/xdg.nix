{ lib, ... }: {
  xdg = {
    enable = true;
    autostart.enable = false;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications =
        let
          forTypes = desktop: types: lib.genAttrs types (_: [ desktop ]);
        in
        forTypes "zen-beta.desktop" [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/mailto"
        ]
        // forTypes "imv.desktop" [
          "image/avif"
          "image/bmp"
          "image/gif"
          "image/heif"
          "image/jpeg"
          "image/jpg"
          "image/jxl"
          "image/pjpeg"
          "image/png"
          "image/qoi"
          "image/svg+xml"
          "image/tiff"
          "image/tiff-fx"
          "image/webp"
          "image/x-bmp"
          "image/x-farbfeld"
          "image/x-png"
        ]
        // forTypes "mpv.desktop" [
          "application/ogg"
          "application/vnd.apple.mpegurl"
          "application/vnd.ms-asf"
          "application/x-matroska"
          "audio/aac"
          "audio/ac3"
          "audio/flac"
          "audio/m4a"
          "audio/mp4"
          "audio/mpeg"
          "audio/ogg"
          "audio/opus"
          "audio/vnd.rn-realaudio"
          "audio/wav"
          "audio/webm"
          "audio/x-aiff"
          "audio/x-ape"
          "audio/x-flac"
          "audio/x-m4a"
          "audio/x-matroska"
          "audio/x-mpegurl"
          "audio/x-ms-wma"
          "audio/x-scpls"
          "audio/x-vorbis+ogg"
          "audio/x-wav"
          "video/3gpp"
          "video/3gpp2"
          "video/mp2t"
          "video/mp4"
          "video/mpeg"
          "video/ogg"
          "video/quicktime"
          "video/webm"
          "video/x-flv"
          "video/x-m4v"
          "video/x-matroska"
          "video/x-ms-asf"
          "video/x-msvideo"
          "video/x-ms-wmv"
          "video/x-theora+ogg"
        ]
        // forTypes "org.pwmt.zathura-pdf-mupdf.desktop" [
          "application/pdf"
        ]
        // forTypes "org.pwmt.zathura-cb.desktop" [
          "application/vnd.comicbook+zip"
          "application/vnd.comicbook-rar"
          "application/x-cb7"
          "application/x-cbr"
          "application/x-cbt"
          "application/x-cbz"
        ]
        // forTypes "org.pwmt.zathura-djvu.desktop" [
          "image/vnd.djvu"
          "image/vnd.djvu+multipage"
        ]
        // forTypes "onlyoffice-desktopeditors.desktop" [
          "application/epub+zip"
          "application/msword"
          "application/msword-template"
          "application/oxps"
          "application/rtf"
          "application/vnd.ms-excel"
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
          "application/vnd.ms-excel.sheet.macroEnabled.12"
          "application/vnd.ms-excel.template.macroEnabled.12"
          "application/vnd.ms-powerpoint"
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
          "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
          "application/vnd.ms-powerpoint.template.macroEnabled.12"
          "application/vnd.ms-word.document.macroEnabled.12"
          "application/vnd.ms-word.template.macroEnabled.12"
          "application/vnd.ms-xpsdocument"
          "application/vnd.oasis.opendocument.presentation"
          "application/vnd.oasis.opendocument.presentation-template"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.oasis.opendocument.spreadsheet-template"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.oasis.opendocument.text-template"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
          "application/vnd.openxmlformats-officedocument.presentationml.template"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
          "text/csv"
          "text/tab-separated-values"
        ]
        // forTypes "org.gnome.FileRoller.desktop" [
          "application/gzip"
          "application/vnd.rar"
          "application/x-7z-compressed"
          "application/x-bzip"
          "application/x-bzip-compressed-tar"
          "application/x-compress"
          "application/x-compressed-tar"
          "application/x-cpio"
          "application/x-gzip"
          "application/x-lz4"
          "application/x-lz4-compressed-tar"
          "application/x-lzip"
          "application/x-lzip-compressed-tar"
          "application/x-lzma"
          "application/x-lzma-compressed-tar"
          "application/x-rar"
          "application/x-rar-compressed"
          "application/x-tar"
          "application/x-xz"
          "application/x-xz-compressed-tar"
          "application/x-zip-compressed"
          "application/x-zstd-compressed-tar"
          "application/zip"
          "application/zstd"
        ]
        // forTypes "nvim.desktop" [
          "application/javascript"
          "application/json"
          "application/toml"
          "application/x-shellscript"
          "application/xml"
          "application/yaml"
          "text/css"
          "text/javascript"
          "text/markdown"
          "text/plain"
          "text/x-c"
          "text/x-c++"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-go"
          "text/x-java"
          "text/x-lua"
          "text/x-makefile"
          "text/x-nix"
          "text/x-python"
          "text/x-rust"
          "text/x-script.python"
          "text/x-sh"
          "text/x-tex"
          "text/x-toml"
          "text/x-yaml"
          "text/xml"
        ]
        // {
          "inode/directory" = [ "yazi.desktop" ];
        };
    };

    dataFile."backgrounds/fantasy-woods.jpg".source = ../config/wallpaper/fantasy-woods.jpg;
  };

}
