{ inputs, pkgs, lib, ... }:

{
  imports = [ inputs.lanzaboote.nixosModules.default ];
  environment.systemPackages = [ pkgs.sbctl ];
  boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot.enable = lib.mkForce false;
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };
  };
}
