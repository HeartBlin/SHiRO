{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    package = pkgs.steam.override {
      extraArgs = "-system-composer";
      extraEnv = {
        PROTON_NO_WM_DECORATION = 1;
        PROTON_USE_WOW64 = 1;
      };
    };
  };

  # SteamOS kernel tweaks
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "kernel.split_lock_mitigate" = 0;
    "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    "net.ipv4.tcp_fin_timeout" = 5;
  };

  # Tweaks
  boot.kernelModules = [ "ntsync" ];
  environment.sessionVariables = {
    PROTON_ENABLE_WAYLAND = 1;
    PROTON_USE_WOW64 = 1;
    VKD3D_SWAPCHAIN_LATENCY_FRAMES = 1;
  };
}
