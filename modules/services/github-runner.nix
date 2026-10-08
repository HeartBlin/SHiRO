{ config, lib, pkgs, self, ... }:

let
  repos = {
    kuro = "https://github.com/HeartBlin/KURO";
    shiro = "https://github.com/HeartBlin/SHiRO";
    hjem-shim = "https://github.com/HeartBlin/hjem-shim";
  };

  mkRunner = _name: url: {
    enable = true;
    inherit url;
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
in {
  age.secrets.github-app-key.file = "${self}/secrets/github/app-key.age";
  nix.settings.allowed-users = lib.mapAttrsToList (name: _: "github-runner-${name}") repos;
  services.github-runners = lib.mapAttrs mkRunner repos;
}
