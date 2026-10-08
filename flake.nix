{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    # Cached by own Hydra instance
    kuro.url = "github:HeartBlin/KURO";
    hjem.url = "github:HeartBlin/hjem-shim";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "";
      };
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (inputs) self;
    inherit (inputs.nixpkgs) lib;

    system = "x86_64-linux";
    alejandra = inputs.kuro.packages.${system}.alejandra-custom;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # Find all hosts
    nixosConfigurations =
      builtins.readDir ./clients
      |> lib.filterAttrs (n: v: v == "directory" && builtins.pathExists ./clients/${n}/config.nix)
      |> lib.mapAttrs (host: _:
        lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [ ./clients/${host}/config.nix ];
        });

    # Find all modules
    nixosModules =
      ./modules
      |> lib.filesystem.listFilesRecursive
      |> (lib.filter (p: lib.hasSuffix ".nix" p && !lib.hasPrefix "_" (baseNameOf p)))
      |> (map (p: lib.nameValuePair (lib.removeSuffix ".nix" (baseNameOf p)) p))
      |> lib.listToAttrs;

    # For `nix fmt`
    formatter.${system} = pkgs.writeShellApplication {
      name = "format";
      text = ''deadnix --edit "$@" && statix fix "$@" && alejandra "$@"'';
      runtimeInputs = [
        alejandra
        pkgs.deadnix
        pkgs.statix
      ];
    };

    # For `nix flake check`
    checks.${system}.overall = let
      yamllintConfig = builtins.toFile "yamllint.yaml" (builtins.toJSON {
        extends = "default";
        ignore = [ "**/*sops*" "**/*secrets*" ];
        rules = {
          brackets = {
            min-spaces-inside = 0;
            max-spaces-inside = 1;
          };
          document-start = "disable";
          line-length.max = 120;
          truthy.allowed-values = [ "true" "false" "on" ];
        };
      });
    in
      pkgs.runCommand "check-overall" { } ''
        cd ${self}
        ${lib.getExe alejandra} --check .
        ${lib.getExe pkgs.deadnix} --fail .
        ${lib.getExe pkgs.statix} check . -i clients/Void/config.nix
        ${lib.getExe pkgs.yamllint} -c ${yamllintConfig} .
        touch $out
      '';
  };
}
