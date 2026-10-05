{ lib, modulesPath, self, ... }:

{
  imports = with self.nixosModules; [
    # Apps
    git
    shell

    # Core
    networkmanager
    nix
    user

    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  ## Module Overriding
  # user.nix
  users.users.primaryUser.name = "nixos";

  ## Host Specific
  # For niceties sake. Void has a key broken.
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p1866*
      KEYBOARD_KEY_700e4=left
      KEYBOARD_KEY_70050=reserved
  '';

  # Get this flake in the ISO.
  environment.etc."iNFRA".source = lib.cleanSource "${self}";

  image.baseName = lib.mkForce "Origin";
  isoImage = {
    volumeID = lib.mkForce "Origin";
    squashfsCompression = "zstd -Xcompression-level 22";
    compressImage = false; # redundant since zstd goes crazy style on it
  };

  # System ID
  networking.hostName = "Origin";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";
}
