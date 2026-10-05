{ inputs, pkgs, ... }:

{
  imports = [ inputs.nix-index-database.nixosModules.default ];
  config = {
    environment.sessionVariables.TMPDIR = "/tmp";
    users.users.primaryUser.shell = pkgs.fish;
    programs = {
      command-not-found.enable = false;
      fish = {
        enable = true;
        shellAliases.ls = "${pkgs.eza}/bin/eza -l --icons --git";
        interactiveShellInit = "set fish_greeting";
      };

      starship = {
        enable = true;
        settings = {
          format = "$directory$git_branch$git_status$character";
          add_newline = false;
          directory.disabled = false;
          character = {
            disabled = false;
            success_symbol = "[λ](bold purple)";
            error_symbol = "[λ](bold red)";
          };
        };
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        flags = [ "--cmd cd" ];
      };

      nix-index-database.comma.enable = true;
      nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
