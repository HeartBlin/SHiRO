{ config, self, ... }:

{
  age.secrets.beszel.file = "${self}/secrets/beszel/env.age";
  services.beszel = {
    hub = {
      enable = true;
      host = "[::1]";
      port = 8100;
      environment.TRUSTED_AUTH_HEADER = "X-Beszel-User";
    };

    agent = {
      enable = true;
      smartmon.enable = true;
      environmentFile = config.age.secrets.beszel.path;
      environment = {
        HUB_URL = "http://[::1]:8100";
        DISABLE_SSH = "true";
      };
    };
  };
}
