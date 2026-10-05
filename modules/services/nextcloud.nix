{ config, pkgs, self, ... }:

{
  age.secrets.nextcloud = {
    file = "${self}/secrets/nextcloud/admin.age";
    owner = "root";
    mode = "0400";
  };

  users.users.nextcloud.extraGroups = [ "music" "store" ];
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud35;

      hostName = "files.heartblin.eu";
      https = true;

      appstoreEnable = false;
      database.createLocally = true;
      configureRedis = true;

      maxUploadSize = "5G";
      fastcgiTimeout = 300;

      config = {
        dbtype = "mysql";
        adminpassFile = config.age.secrets.nextcloud.path;
      };

      settings = {
        trusted_proxies = [ "::1" ];
        overwriteprotocol = "https";
        "overwrite.cli.url" = "https://files.heartblin.eu";

        # To satisfy Nextcloud config check
        maintenance_window_start = 1;
        default_phone_region = "RO";
        log_type = "systemd";
      };
    };

    nginx = {
      enable = true;
      virtualHosts."files.heartblin.eu" = {
        listen = [ { addr = "[::1]"; port = 8090; } ];
        rejectSSL = true;
      };
    };
  };
}
