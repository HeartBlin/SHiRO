{ config, pkgs, self, ... }:

{
  age.secrets.github-app-key.file = "${self}/secrets/github/app-key.age";
  nix.allowedUsers = [ "github-runner-kuro" "github-runner-shiro" ];
  services.github-runners = {
    kuro = {
      enable = true;
      url = "https://github.com/HeartBlin/KURO";
      ephemeral = true;
      replace = true;
      extraLabels = [ "nixos" ];
      extraPackages = [
        pkgs.gitMinimal
        pkgs.openssh
        pkgs.nix-update
        config.nix.package
      ];

      githubApp = {
        id = 5202800;
        login = "HeartBlin";
        privateKeyFile = config.age.secrets.github-app-key.path;
      };
    };

    shiro = {
      enable = true;
      url = "https://github.com/HeartBlin/SHiRO";
      ephemeral = true;
      replace = true;
      extraLabels = [ "nixos" ];
      extraPackages = [
        pkgs.gitMinimal
        pkgs.openssh
        pkgs.nix-update
        config.nix.package
      ];

      githubApp = {
        id = 5202800;
        login = "HeartBlin";
        privateKeyFile = config.age.secrets.github-app-key.path;
      };
    };
  };
}
