{ inputs, pkgs, self, ... }:

{
  imports = with self.nixosModules; [
    # Apps
    nh
    shell

    # Core
    bootloader
    chrony
    networkd
    nix
    user

    # Desktop
    cage

    # Hardware
    amd

    # Services
    beszel
    caddy
    ddns-updater
    github-runner
    hydra
    jellyfin
    nextcloud
    openssh
    restic
    slskd
    vaultwarden

    # Misc
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
    ./disko.nix
  ];

  ## Module Overriding
  # user.nix
  users.users.primaryUser = {
    name = "server";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpgPRSO60dVRKcX04oyk/0TW+uSQwSlasKh4e87EMLy heartblin@Void"
    ];
  };

  ## Host Specifics
  # Folders and Permissions
  users.groups = {
    store = { gid = 100001; };
    music = { gid = 100002; };
  };

  systemd.tmpfiles.rules = [
    "z /data/music 2770 root music"
    "z /data/store 2770 root store"
  ];

  # I want fstrim & scrubbing
  services.fstrim.enable = true;

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # I want Mesa
  hardware.graphics.enable = true;

  # Wireguard - Void
  networking = {
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" "fd71:3362:beef:1::1/64" ];
      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/private.key";
      peers = [
        {
          publicKey = "8PrXmK62578I5QfpfTRn27n6m6KNRkM2nWobmN/1aFg=";
          presharedKeyFile = "/etc/wireguard/psk.key";
          allowedIPs = [ "10.100.0.2/32" "fd71:3362:beef:1::2/128" ];
        }
      ];
    };

    firewall = {
      allowedUDPPorts = [ 51820 ];
      interfaces."wg0".allowedTCPPorts = [ 22 ];
    };
  };

  # System ID
  networking.hostName = "Reason";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";
}
