{ config, pkgs, self, ... }:

{
  age.secrets.github-app-key.file = "${self}/secrets/github/app-key.age";
  nix.allowedUsers = [ "github-runner-haiiro" ];
  services.github-runners.haiiro = {
    enable = true;
    url = "https://github.com/HeartBlin/Kuro";
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
}
