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
      hydraURL = "https://hydra.heartblin.eu";
      notificationSender = "hydra@heartblin.eu";
      listenHost = "localhost";
      useSubstitutes = true;
      queueRunner = {
        grpc.unixSocket = "/run/hydra-queue-runner-grpc.sock";
        settings = {
          tokenPaths = [ config.age.secrets.hydra.path ];
          remoteStoreAddr = [ "file:///var/lib/hydra-cache?secret-key=/etc/nix/hydra-cache.secret&compression=zstd&write-nar-listing=1" ];
        };
      };
    };

    hydra-builder = {
      enable = true;
      settings.useSubstitutes = true;
      queueRunnerAddr = "unix:///run/hydra-queue-runner-grpc.sock";
      authorizationFile = config.age.secrets.hydra.path;
    };

    caddy.virtualHosts."cache.heartblin.eu".extraConfig = ''
      root * /var/lib/hydra-cache
      file_server
    '';
  };

  nix.settings.allowed-users = [ "hydra" "hydra-www" ];
  users.groups.hydra-cache.members = [ "caddy" ];
  systemd = {
    services.hydra-queue-runner = {
      serviceConfig.ReadWritePaths = [ "/var/lib/hydra-cache" ];
      path = [ config.nix.package ];
    };
    tmpfiles.rules = [ "d /var/lib/hydra-cache 2750 hydra-queue-runner hydra-cache -" ];
    sockets.hydra-queue-runner-grpc.socketConfig = {
      SocketUser = "hydra-builder";
      SocketGroup = "hydra";
      SocketMode = "0660";
    };
  };
}
