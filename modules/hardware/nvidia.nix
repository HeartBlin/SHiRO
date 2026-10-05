{ config, ... }:

{
  nixpkgs.config.cudaSupport = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      branch = "bleeding_edge";
      open = true;
      modesetting.enable = true;

      nvidiaSettings = false;
      powerManagement.enable = true;
      dynamicBoost.enable = config.hardware.nvidia.prime.offload.enable;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot = {
    kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
  };
}
