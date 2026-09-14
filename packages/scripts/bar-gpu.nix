{ pkgs, nvidia }:
pkgs.writeShellApplication {
  name = "bar-gpu";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.wezterm
    pkgs.nvtopPackages.nvidia
    nvidia
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    [[ ''${BLOCK_BUTTON:-} == 1 ]] && wezterm start --always-new-process -- nvtop >/dev/null 2>&1 &

    if ! stats=$(timeout 3s nvidia-smi --id=0 \
      --query-gpu=utilization.gpu,temperature.gpu \
      --format=csv,noheader,nounits 2>/dev/null); then
      printf '\U000F08AE  n/a\n'
      exit 0
    fi

    IFS=', ' read -r utilization temperature <<<"$stats"
    [[ $utilization =~ ^[0-9]+$ && $temperature =~ ^[0-9]+$ ]] || {
      printf '\U000F08AE  n/a\n'
      exit 0
    }
    if ((temperature >= 85)); then
      printf '󰢮 %s%% %s°C\n' "$utilization" "$temperature"
    else
      printf '󰢮 %s%% %s°C\n' "$utilization" "$temperature"
    fi
  '';
}
