{ pkgs }:
pkgs.writeShellApplication {
  name = "screenrecord";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.libnotify
    pkgs.dmenu
    pkgs.slop
    pkgs.xrandr
    pkgs.xdotool
    pkgs.util-linux
    pkgs.xdg-user-dirs
    pkgs.systemd
    pkgs.procps
    pkgs.xautolock
    pkgs.xset
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    videos_directory=$(xdg-user-dir VIDEOS 2>/dev/null || true)
    directory="''${videos_directory:-''${XDG_VIDEOS_DIR:-$HOME/Videos}}/Recordings"
    statefile="''${XDG_RUNTIME_DIR:-/run/user/$UID}/screenrecord.state"

    recording_is_live() {
      local current_start_time process_state executable
      [[ ''${pid:-} =~ ^[0-9]+$ && ''${start_time:-} =~ ^[0-9]+$ ]] || return 1
      kill -0 "$pid" 2>/dev/null || return 1
      read -r process_state current_start_time < <(awk '{ print $3, $22 }' "/proc/$pid/stat" 2>/dev/null) || return 1
      [[ $process_state != Z ]] || return 1
      [[ $current_start_time == "$start_time" ]] || return 1
      executable=$(readlink -f "/proc/$pid/exe" 2>/dev/null) || return 1
      [[ $executable == "${pkgs.gpu-screen-recorder}/bin/.wrapped/gpu-screen-recorder" ]]
    }

    read_state() {
      [[ -f $statefile ]] || return 1
      {
        IFS= read -r pid || return 1
        IFS= read -r start_time || return 1
        IFS= read -r file || return 1
      } <"$statefile"
    }

    wait_for_inhibitor() {
      flock -w 5 "$statefile.inhibit.lock" true || {
        notify-send -u critical -a Recording 'Recording cleanup is still running' \
          'Wait before starting another recording.'
        exit 1
      }
    }

    stop_recording() {
      local attempt
      kill -INT "$pid"
      for ((attempt = 0; attempt < 50; attempt++)); do
        recording_is_live || break
        sleep 0.1
      done
      if recording_is_live; then
        notify-send -u critical -a Recording 'Recording did not stop' \
          'The recorder is still finalizing. Try again before starting another recording.'
        exit 1
      fi
      wait_for_inhibitor
      rm -f "$statefile"
      if [[ -s $file ]]; then
        notify-send -a Recording 'Recording saved' "$file"
      else
        notify-send -u critical -a Recording 'Recording failed' \
          'No completed recording was written.'
        exit 1
      fi
    }

    if [[ ''${1:-} == menu ]]; then
      if read_state && recording_is_live; then
        choice=$(printf '%s\n' 'Stop Recording' | dmenu -p Record) || exit 0
        [[ $choice == 'Stop Recording' ]] || exit 0
        set -- stop
      else
        choice=$(printf '%s\n' 'Record Region' 'Record Screen' | dmenu -p Record) || exit 0
        case "$choice" in
          'Record Region') mode=region ;;
          'Record Screen') mode=output ;;
          *) exit 0 ;;
        esac
        audio=$(printf '%s\n' 'No Audio' 'Microphone' 'Desktop + Microphone' | dmenu -p Audio) || exit 0
        case "$audio" in
          'No Audio') audio=none ;;
          'Microphone') audio=mic ;;
          'Desktop + Microphone') audio=desktop+mic ;;
          *) exit 0 ;;
        esac
        set -- "$mode" "$audio"
      fi
    elif [[ ''${1:-} == inhibit ]]; then
      exec systemd-inhibit --what=idle --who=screenrecord --why='Screen recording' \
        --mode=block "$0" inhibit-watch "''${@:2}"
    elif [[ ''${1:-} == inhibit-watch ]]; then
      shift
      pid=''${1:-}
      start_time=''${2:-}
      [[ $pid =~ ^[0-9]+$ && $start_time =~ ^[0-9]+$ ]] || exit 2
      exec 8>"$statefile.inhibit.lock"
      flock -w 5 8 || exit 1
      recording_is_live || exit 1
      xautolock -disable || exit 1
      trap 'xautolock -enable || true' EXIT
      trap 'exit 130' INT TERM HUP
      printf 'READY\n'
      ticks=0
      while recording_is_live; do
        if ((ticks % 30 == 0)); then
          xset s reset
        fi
        ((ticks += 1))
        sleep 1
      done
      exit 0
    fi

    exec 9>"$statefile.lock"
    flock -n 9 || exit 1

    mode=''${1:-output}
    audio=''${2:-none}
    case "$mode" in
      region | output | stop | status) ;;
      *)
        printf 'usage: screenrecord [region|output] [none|mic|desktop+mic] | stop | status | menu\n' >&2
        exit 2
        ;;
    esac

    if [[ $mode == region || $mode == output ]]; then
      case "$audio" in
        none | mic | desktop+mic) ;;
        *)
          printf 'usage: screenrecord [region|output] [none|mic|desktop+mic] | stop | status | menu\n' >&2
          exit 2
          ;;
      esac
    elif (($# > 1)); then
      printf 'usage: screenrecord [region|output] [none|mic|desktop+mic] | stop | status\n' >&2
      exit 2
    fi

    if read_state && recording_is_live; then
      if [[ $mode == status ]]; then
        printf '%s\n' "$file"
        exit 0
      fi
      stop_recording
      exit 0
    fi

    if [[ $mode == status ]]; then
      printf 'not recording\n'
      exit 1
    fi

    wait_for_inhibitor
    if [[ $mode == stop ]]; then
      rm -f "$statefile"
      notify-send -a Recording 'No active recording'
      exit 0
    fi

    rm -f "$statefile"
    mkdir -p "$directory"
    file="$directory/$(date +%Y-%m-%d_%H-%M-%S-%N).mp4"

    case "$mode" in
      output)
        read -r mouse_x mouse_y < <(xdotool getmouselocation --shell | awk -F= '/^X/{x=$2} /^Y/{y=$2} END{print x, y}')
        if ! monitor=$(xrandr --listmonitors | awk -v x="$mouse_x" -v y="$mouse_y" '
            /^ *[0-9]+:/ {
              if (!match($3, /^([0-9]+)\/[0-9]+x([0-9]+)\/[0-9]+([+-][0-9]+)([+-][0-9]+)$/, d)) next
              if (x >= d[3] && x < d[3] + d[1] && y >= d[4] && y < d[4] + d[2]) { print $NF; exit }
            }'); then
          notify-send -u critical -a Recording 'Recording failed' \
            'Could not determine the monitor under the cursor.'
          exit 1
        fi
        [[ -n $monitor ]] || {
          notify-send -u critical -a Recording 'Recording failed' \
            'Could not determine the monitor under the cursor.'
          exit 1
        }
        args=(-w "$monitor")
        ;;
      region)
        selection=$(slop -f '%w %h %x %y' </dev/null) || exit 0
        read -r width height x y <<<"$selection"
        if ! xrandr --listmonitors | awk -v x="$x" -v y="$y" \
          -v w="$width" -v h="$height" '
            /^ *[0-9]+:/ {
              if (!match($3, /^([0-9]+)\/[0-9]+x([0-9]+)\/[0-9]+([+-][0-9]+)([+-][0-9]+)$/, d)) next
              if (w > 0 && h > 0 &&
                  x >= d[3] && x + w <= d[3] + d[1] &&
                  y >= d[4] && y + h <= d[4] + d[2]) { ok = 1 }
            }
            END { exit !ok }'; then
          notify-send -u critical -a Recording 'Recording failed' \
            'Select a region entirely within one display.'
          exit 1
        fi
        printf -v geometry '%sx%s%+d%+d' "$width" "$height" "$x" "$y"
        args=(-w region -region "$geometry")
        ;;
      *)
        exit 2
        ;;
    esac

    case "$audio" in
      none) audio_args=() ;;
      mic) audio_args=(-a default_input) ;;
      desktop+mic) audio_args=(-a 'default_output|default_input') ;;
      *) exit 2 ;;
    esac

    ${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder "''${args[@]}" -f 60 "''${audio_args[@]}" -c mp4 -o "$file" 9>&- &
    pid=$!
    sleep 0.2
    if ! kill -0 "$pid" 2>/dev/null; then
      wait "$pid" || status=$?
      notify-send -u critical -a Recording 'Recording failed to start' \
        "gpu-screen-recorder exited with status ''${status:-0}."
      exit 1
    fi

    if ! start_time=$(awk '{ print $22 }' "/proc/$pid/stat" 2>/dev/null); then
      wait "$pid" || status=$?
      notify-send -u critical -a Recording 'Recording failed to start' \
        "gpu-screen-recorder exited with status ''${status:-0}."
      exit 1
    fi

    coproc inhibitor { exec "$0" inhibit "$pid" "$start_time" 9>&-; }
    inhibitor_fd=''${inhibitor[0]:-}
    inhibitor_pid=''${inhibitor_PID:-}
    if [[ -z $inhibitor_fd ]] || ! read -r -t 5 ready <&"$inhibitor_fd" || [[ $ready != READY ]]; then
      if [[ -n $inhibitor_pid ]]; then
        kill "$inhibitor_pid" 2>/dev/null || true
        wait "$inhibitor_pid" 2>/dev/null || true
      fi
      kill -INT "$pid" 2>/dev/null || true
      wait "$pid" || true
      wait_for_inhibitor
      notify-send -u critical -a Recording 'Recording failed' 'Could not prevent automatic locking while recording.'
      exit 1
    fi

    statefile_tmp="$statefile.tmp.$pid"
    printf '%s\n%s\n%s\n' "$pid" "$start_time" "$file" >"$statefile_tmp"
    mv "$statefile_tmp" "$statefile"

    notify-send -a Recording 'Recording started' "$file"
  '';
}
