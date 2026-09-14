{ pkgs }:
pkgs.writeShellApplication {
  name = "bar-cpu-temperature";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.wezterm
    pkgs.btop
    pkgs.gawk
    pkgs.procps
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    [[ ''${BLOCK_BUTTON:-} == 1 ]] && wezterm start --always-new-process -- btop >/dev/null 2>&1 &

    read -r _ user nice system idle iowait irq softirq steal _ </proc/stat || exit 1
    busy1=$((user + nice + system + irq + softirq + steal))
    total1=$((busy1 + idle + iowait))
    sleep 0.25
    read -r _ user nice system idle iowait irq softirq steal _ </proc/stat || exit 1
    busy2=$((user + nice + system + irq + softirq + steal))
    total2=$((busy2 + idle + iowait))
    usage=0
    if ((total2 > total1)); then
      usage=$((100 * (busy2 - busy1) / (total2 - total1)))
    fi

    temp='''
    for sensor_directory in /sys/class/hwmon/hwmon*; do
      if IFS= read -r sensor_name 2>/dev/null <"$sensor_directory/name" && [[ $sensor_name == k10temp ]]; then
        inputs=()
        fallback="$sensor_directory/temp1_input"
        for label in "$sensor_directory"/temp*_label; do
          [[ -r $label ]] || continue
          input="''${label%_label}_input"
          [[ -r $input ]] || continue
          IFS= read -r sensor_label <"$label" || continue
          case $sensor_label in
            Tccd*) inputs+=("$input") ;;
            Tdie) fallback="$input" ;;
          esac
        done
        if ((''${#inputs[@]} == 0)) && [[ -r $fallback ]]; then
          inputs+=("$fallback")
        fi
        if ((''${#inputs[@]} > 0)); then
          temp=$(awk '{ sum += $1 } END { if (NR) printf "%.0f", sum / NR / 1000 }' "''${inputs[@]}")
        fi
        break
      fi
    done

    if [[ -z $temp ]]; then
      printf ' %s%% n/a\n' "$usage"
    else
      printf ' %s%% %s°C\n' "$usage" "$temp"
    fi
  '';
}
