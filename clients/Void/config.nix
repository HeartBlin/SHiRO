{ inputs, pkgs, self, ... }:

{
  imports = with self.nixosModules; [
    # Apps
    bottles
    chromium
    gaming
    ghostty
    git
    mangohud
    nh
    shell
    vscodium

    # Core
    bootloader
    chrony
    i18n
    networkmanager
    nix
    user
    zram

    # Desktop
    gnome

    # Hardware
    amd
    asus
    audio
    bluetooth
    nvidia

    # Security
    keys

    # Misc
    inputs.disko.nixosModules.default
    ./disko.nix
  ];

  ## Module Overriding
  # git.nix
  programs.git.config.user = {
    name = "HeartBlin";
    email = "161874560+HeartBlin@users.noreply.github.com";
    signingkey = "/home/heartblin/.ssh/GitHub";
  };

  # nh.nix
  programs.nh.flake = "/home/heartblin/Public/GitHub/SHiRO";

  # nvidia.nix
  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1@0:0:0";
    amdgpuBusId = "PCI:5@0:0:0";
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
  };

  # user.nix
  users.users.primaryUser = {
    name = "heartblin";
    description = "HeartBlin";
  };

  ## Host Specifics
  # My left arrow key is broken. Remap to right control, and disable it
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p1866*
      KEYBOARD_KEY_700e4=left
      KEYBOARD_KEY_70050=reserved
  '';

  # I want fstrim
  services.fstrim.enable = true;

  # Some kernel changes
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" ];
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
  };

  # SSH Convenience
  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile /home/heartblin/.ssh/GitHub
      IdentitiesOnly yes

    Host Reason
      HostName fd71:3362:beef:1::1
      Port 22
      User server
      IdentityFile /home/heartblin/.ssh/Reason
      IdentitiesOnly yes
  '';

  # Wireguard - Reason
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ "/etc/wireguard/nm.env" ];
    profiles.wg0 = {
      connection = {
        id = "Reason";
        type = "wireguard";
        interface-name = "wg0";
        autoconnect = false;
      };

      wireguard.private-key = "$WG_PRIVATE_KEY";
      "wireguard-peer.gSlbzoZW6NU4Ld+uVBlPP6FMVSYZUEqMR+h1fDpH1ig=" = {
        endpoint = "heartblin.eu:51820";
        allowed-ips = "10.100.0.0/24;fd71:3362:beef:1::/64;";
        persistent-keepalive = "25";
        preshared-key = "$WG_PSK";
        preshared-key-flags = "0";
      };

      ipv4 = {
        method = "manual";
        address1 = "10.100.0.2/24";
        never-default = "true";
      };

      ipv6 = {
        method = "manual";
        address1 = "fd71:3362:beef:1::2/64";
        never-default = "true";
      };
    };
  };

  # System ID
  networking.hostName = "Void";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";
}
