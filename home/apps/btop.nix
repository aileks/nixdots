{ ... }:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  programs.btop.settings = {
    "color_theme" = "cinder-grove";
    "theme_background" = false;
    "truecolor" = true;
    "force_tty" = false;
    "disable_presets" = "Off";
    "presets" =
      "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
    "vim_keys" = true;
    "disable_mouse" = false;
    "rounded_corners" = false;
    "terminal_sync" = true;
    "graph_symbol" = "braille";
    "graph_symbol_cpu" = "default";
    "graph_symbol_gpu" = "default";
    "graph_symbol_mem" = "default";
    "graph_symbol_net" = "default";
    "graph_symbol_proc" = "default";
    "shown_boxes" = "cpu mem net proc";
    "update_ms" = 2000;
    "proc_sorting" = "cpu direct";
    "proc_reversed" = false;
    "proc_tree" = false;
    "proc_colors" = true;
    "proc_gradient" = true;
    "proc_per_core" = true;
    "proc_mem_bytes" = true;
    "proc_cpu_graphs" = true;
    "proc_info_smaps" = false;
    "proc_left" = false;
    "proc_filter_kernel" = false;
    "proc_follow_detailed" = true;
    "proc_aggregate" = false;
    "keep_dead_proc_usage" = false;
    "cpu_graph_upper" = "Auto";
    "cpu_graph_lower" = "Auto";
    "show_gpu_info" = "Auto";
    "cpu_invert_lower" = true;
    "cpu_single_graph" = false;
    "cpu_bottom" = false;
    "show_uptime" = true;
    "show_cpu_watts" = true;
    "check_temp" = true;
    "cpu_sensor" = "Auto";
    "show_coretemp" = true;
    "cpu_core_map" = "";
    "temp_scale" = "celsius";
    "base_10_sizes" = false;
    "show_cpu_freq" = true;
    "freq_mode" = "first";
    "clock_format" = "%X";
    "background_update" = true;
    "custom_cpu_name" = "";
    "disks_filter" = "";
    "mem_graphs" = true;
    "mem_below_net" = false;
    "zfs_arc_cached" = true;
    "show_swap" = true;
    "swap_disk" = true;
    "show_disks" = true;
    "only_physical" = true;
    "use_fstab" = true;
    "zfs_hide_datasets" = false;
    "disk_free_priv" = false;
    "show_io_stat" = true;
    "io_mode" = false;
    "io_graph_combined" = false;
    "io_graph_speeds" = "";
    "swap_upload_download" = false;
    "net_download" = 100;
    "net_upload" = 100;
    "net_auto" = false;
    "net_sync" = true;
    "net_iface" = "";
    "base_10_bitrate" = "Auto";
    "show_battery" = true;
    "selected_battery" = "Auto";
    "show_battery_watts" = true;
    "log_level" = "WARNING";
    "save_config_on_exit" = true;
    "nvml_measure_pcie_speeds" = true;
    "rsmi_measure_pcie_speeds" = true;
    "gpu_mirror_graph" = true;
    "shown_gpus" = "nvidia amd intel apple";
    "custom_gpu_name0" = "";
    "custom_gpu_name1" = "";
    "custom_gpu_name2" = "";
    "custom_gpu_name3" = "";
    "custom_gpu_name4" = "";
    "custom_gpu_name5" = "";
  };
  xdg.configFile."btop/themes/cinder-grove.theme".text = ''
    theme[main_bg]="${colors.background}"
    theme[main_fg]="${colors.text}"
    theme[title]="${colors.bright}"
    theme[hi_fg]="${colors.blue}"
    theme[selected_bg]="${colors.muted}"
    theme[selected_fg]="${colors.bright}"
    theme[inactive_fg]="${colors.muted}"
    theme[proc_misc]="${colors.blue}"
    theme[div_line]="${colors.blue}"

    theme[process_start]="${colors.subtle}"
    theme[process_mid]="${colors.green}"
    theme[process_end]="${colors.red}"

    theme[cpu_box]="#8d5533"
    theme[mem_box]="${colors.blue}"
    theme[net_box]="${colors.cyan}"
    theme[proc_box]="${colors.purple}"

    theme[temp_start]="${colors.cyan}"
    theme[temp_mid]="${colors.yellow}"
    theme[temp_end]="${colors.red}"

    theme[cpu_start]="${colors.secondary}"
    theme[cpu_mid]="${colors.yellow}"
    theme[cpu_end]="${colors.red}"

    theme[free_start]="${colors.surface}"
    theme[free_mid]="${colors.muted}"
    theme[free_end]="${colors.subtle}"

    theme[cached_start]="${colors.container}"
    theme[cached_mid]="${colors.text}"
    theme[cached_end]="${colors.cyan}"

    theme[available_start]="${colors.red}"
    theme[available_mid]="${colors.blue}"
    theme[available_end]="${colors.cyan}"

    theme[used_start]="${colors.container}"
    theme[used_mid]="#c87546"
    theme[used_end]="${colors.red}"

    theme[download_start]="${colors.surface}"
    theme[download_mid]="${colors.blue}"
    theme[download_end]="${colors.green}"

    theme[upload_start]="${colors.surface}"
    theme[upload_mid]="${colors.cyan}"
    theme[upload_end]="${colors.green}"
  '';
}
