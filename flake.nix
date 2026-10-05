{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    systems.url = "github:nix-systems/x86_64-linux";
    kuro.url = "github:HeartBlin/KURO";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
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
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    inherit (inputs) self;
    inherit (inputs.nixpkgs) lib;

    forAllSystems = x:
      lib.genAttrs (import inputs.systems) (
        system:
          x {
            inherit system;
            pkgs = inputs.nixpkgs.legacyPackages.${system};
            alejandra = inputs.kuro.packages.${system}.alejandra-custom;
          }
      );
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

    # For the ISOs
    hydraJobs = self.packages;
    packages."x86_64-linux" = let
      ISOs = [ "Origin" "Finality" ];
      mkIso = name:
        pkgs.runCommand "${name}.iso" { } ''
          cp ${self.nixosConfigurations.${name}.config.system.build.isoImage}/iso/${name}.iso $out
        '';
    in
      lib.genAttrs ISOs mkIso;

    # For `nix fmt`
    formatter = forAllSystems ({ pkgs, alejandra, ... }:
      pkgs.writeShellApplication {
        name = "format";
        runtimeInputs = [ alejandra pkgs.deadnix pkgs.statix ];
        text = ''
          deadnix --edit "$@"
          statix fix "$@"
          alejandra  "$@"
        '';
      });

    # For `nix flake check`
    checks = forAllSystems ({ pkgs, alejandra, ... }: let
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
    in {
      overall = pkgs.runCommand "check-overall" { } ''
        cd ${self}
        ${inputs.nixpkgs.lib.getExe alejandra} --check .
        ${inputs.nixpkgs.lib.getExe pkgs.deadnix} --fail .
        ${inputs.nixpkgs.lib.getExe pkgs.statix} check . -i clients/Void/config.nix
        ${inputs.nixpkgs.lib.getExe pkgs.yamllint} -c ${yamllintConfig} .
        touch $out
      '';
    });
  };
}
