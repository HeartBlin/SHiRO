{ config, self, ... }:

{
  age.secrets.slskd = {
    file = "${self}/secrets/slskd/env.age";
    mode = "0400";
  };

  services.slskd = {
    enable = true;
    environmentFile = config.age.secrets.slskd.path;
    openFirewall = true; # This is for the P2P listener
    settings = {
      shares.directories = [ "[Music]/data/music" ];
      soulseek.listen_port = 50300;
      web = {
        ip_address = "[::1]";
        port = 5030; # WebUI
      };
    };
  };

  systemd.services.slskd.serviceConfig = {
    SupplementaryGroups = [ "music" ];
    ReadOnlyPaths = [ "/data/music" ];
  };
}
