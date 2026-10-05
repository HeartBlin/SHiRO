{ pkgs, ... }:

{
  boot.kernelParams = [ "i8042.nokbd" ];
  services = {
    supergfxd.enable = true;
    asusd.enable = true;
  };

  systemd.services.asusd-aura-zones = {
    description = "Do the correct colors";
    wantedBy = [ "multi-user.target" ];
    after = [ "asusd.service" ];
    requires = [ "asusd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = let
        aura = "${pkgs.asusctl}/bin/asusctl aura effect static";
      in [
        "${aura} --zone 1 --colour 00ff00"
        "${aura} --zone 2 --colour 00ffff"
        "${aura} --zone 3 --colour 0000ff"
        "${aura} --zone 4 --colour ff00ff"
      ];
    };
  };
}
