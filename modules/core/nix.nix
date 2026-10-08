{ config, inputs, lib, pkgs, ... }:

{
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  nixpkgs.config = {
    allowAliases = false;
    allowBroken = false;
    allowUnfree = true;
    allowUnsupportedSystem = false;
    nvidia.acceptLicense = true;
  };

  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    registry =
      inputs
      |> lib.filterAttrs (_: lib.isType "flake")
      |> (lib.mapAttrs (_: flake: { inherit flake; }));

    settings = {
      nix-path = lib.mapAttrsToList (n: v: "${n}=${v.flake}") config.nix.registry;
      flake-registry = "";
      auto-optimise-store = true;
      allow-import-from-derivation = true;
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0;
      sandbox = true;
      sandbox-fallback = false;
      use-cgroups = true;
      use-xdg-base-directories = true;
      warn-dirty = false;
      experimental-features = [
        "cgroups"
        "flakes"
        "nix-command"
        "git-hashing"
        "verified-fetches"
        "pipe-operators"
      ];

      allowed-users = [ "@wheel" ];
      trusted-users = [ "@wheel" ];

      connect-timeout = 5;
      download-attempts = 2;
      fallback = true; # In case Reason is dead

      substituters = [
        "https://cache.nixos.org"
        "https://cache.heartblin.eu"
      ];

      trusted-substituters = [
        "https://cache.nixos.org"
        "https://cache.heartblin.eu"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.heartblin.eu-1:XicnTDFCv9Nfhfz7hgQi1AoBqs5z5xTmzhTydB+tK6Q="
      ];
    };
  };
}
