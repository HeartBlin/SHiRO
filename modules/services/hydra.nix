{ config, self, ... }:

{
  age.secrets.hydra = {
    file = "${self}/secrets/hydra/token.age";
    group = "hydra";
    mode = "0440";
  };

  services = {
    hydra = {
      enable = true;
      listenHost = "localhost";
      port = 3000;
      hydraURL = "https://hydra.heartblin.eu";
      notificationSender = "hydra@heartblin.eu";
      extraConfig = ''server_store_uri = file:///var/lib/hydra-cache'';
      queueRunner = {
        settings = {
          useSubstitutes = true;
          tokenPaths = [ config.age.secrets.hydra.path ];
          remoteStoreAddr = [ "file:///var/lib/hydra-cache?secret-key=/etc/nix/hydra-cache.secret&compression=zstd&write-nar-listing=1" ];
        };

        grpc = {
          address = "[::1]";
          port = 50051;
        };
      };
    };

    hydra-builder = {
      enable = true;
      queueRunnerAddr = "http://[::1]:50051";
      authorizationFile = config.age.secrets.hydra.path;
    };

    caddy.virtualHosts."cache.heartblin.eu".extraConfig = ''
      root * /var/lib/hydra-cache
      file_server
    '';
  };

  nix = { settings.allowed-users = [ "hydra" "hydra-www" ]; };
  systemd = {
    services.hydra-queue-runner.serviceConfig.ReadWritePaths = [ "/var/lib/hydra-cache" ];
    tmpfiles.rules = [ "d /var/lib/hydra-cache 0755 hydra-queue-runner hydra - -" ];
  };
}
