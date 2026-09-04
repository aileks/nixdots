{
  config,
  inputs,
  installation,
  pkgs,
  ...
}:

let
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "610.57.04";
    sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
    sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
    openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
    settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
    persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
  };

  xorgSuspendVt = pkgs.writeShellScript "xorg-suspend-vt" ''
    set -eu
    umask 077

    state_file=/run/xorg-suspend-vt

    validate_vt() {
      case "$1" in
        "" | *[!0-9]*) return 1 ;;
      esac

      [ "$1" -ge 1 ] && [ "$1" -le 63 ]
    }

    case "''${1-}" in
      pre)
        ${pkgs.coreutils}/bin/rm -f "$state_file"

        if ! active_session="$(${pkgs.systemd}/bin/loginctl show-seat seat0 --property=ActiveSession --value)"; then
          exit 0
        fi
        [ -n "$active_session" ] || exit 0

        session_type="$(${pkgs.systemd}/bin/loginctl show-session "$active_session" --property=Type --value)"
        [ "$session_type" = x11 ] || exit 0

        active_vt="$(${pkgs.systemd}/bin/loginctl show-session "$active_session" --property=VTNr --value)"
        if ! validate_vt "$active_vt"; then
          echo "invalid Xorg VT: $active_vt" >&2
          exit 1
        fi

        printf '%s\n' "$active_vt" > "$state_file"
        ${pkgs.kbd}/bin/chvt 63
        ;;
      post)
        [ -s "$state_file" ] || exit 0
        IFS= read -r active_vt < "$state_file"

        if ! validate_vt "$active_vt"; then
          echo "invalid saved Xorg VT: $active_vt" >&2
          exit 1
        fi

        ${pkgs.kbd}/bin/chvt "$active_vt"
        ${pkgs.coreutils}/bin/rm -f "$state_file"
        ;;
      *)
        echo "usage: $0 pre|post" >&2
        exit 2
        ;;
    esac
  '';

  system = pkgs.stdenv.hostPlatform.system;

  voxtypePackage = pkgs.symlinkJoin {
    name = "voxtype-vulkan-with-osd";

    paths = [
      inputs.voxtype.packages.${system}.vulkan
      inputs.voxtype.packages.${system}.osd-gtk4
    ];
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  networking.hostName = "hexghost";

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    deviceSection = ''
      Option "HardDPMS" "false"
    '';
  };

  hardware.i2c.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = nvidiaDriver;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
      kernelSuspendNotifier = true;
    };
  };

  systemd.services.systemd-suspend.serviceConfig = {
    ExecStartPre = "${xorgSuspendVt} pre";
    ExecStopPost = "${xorgSuspendVt} post";
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.ydotool.enable = true;

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${installation.user.name} = {
    imports = [
      inputs.voxtype.homeManagerModules.default
    ];

    home.packages = with pkgs; [
      btop-cuda
    ];

    systemd.user.sessionVariables.YDOTOOL_SOCKET = "/run/ydotoold/socket";

    programs.voxtype = {
      enable = true;
      package = voxtypePackage;
      engine = "whisper";
      model.name = "base.en";
      service.enable = true;

      settings = {
        hotkey.enabled = false;
        audio.pause_media = true;
        osd = {
          enabled = true;
          frontend = "gtk4";
          top_margin = 0.6;
        };
        output = {
          mode = "type";
          fallback_to_clipboard = true;
          notification = {
            on_recording_start = false;
            on_recording_stop = false;
            on_transcription = false;
          };
        };
      };
    };
  };
}
