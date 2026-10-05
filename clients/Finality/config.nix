{ lib, modulesPath, pkgs, ... }:

{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  # Host Specific
  # This is a CA workflow Live ISO env
  environment.systemPackages = [ pkgs.step-cli pkgs.step-ca pkgs.openssl ];

  networking = {
    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;
    interfaces = lib.mkForce { };
  };

  image.baseName = lib.mkForce "Finality";
  isoImage = {
    volumeID = lib.mkForce "Finality";
    squashfsCompression = "zstd -Xcompression-level 22";
    compressImage = false; # redundant since zstd goes crazy style on it
  };

  # System ID
  networking.hostName = "Finality";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";
}
