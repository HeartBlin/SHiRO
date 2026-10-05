{ pkgs, ... }:

{
  # I don't use GPG
  programs.gnupg.agent.enable = false;

  # Yubikeys
  environment.systemPackages = [
    pkgs.yubikey-manager
    pkgs.yubikey-personalization
  ];

  services = {
    pcscd.enable = false; # I have Security NFC Keys, soo...
    udev.packages = [
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
    ];
  };

  security.pam = {
    u2f = {
      enable = true;
      settings.cue = true;
    };

    services = {
      login.u2fAuth = true;
      polkit-1.u2fAuth = true;
    };
  };
}
