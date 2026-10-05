{ lib, pkgs, ... }:

let
  inherit (import ./_utils.nix { inherit lib; }) mkDconf;
in {
  environment.systemPackages = [ pkgs.vicinae ];

  # Hides a useless icon
  programs.dconf.profiles.user.databases = mkDconf { } {
    "org/gnome/shell/extensions/vicinae".show-status-indicator = false;
  };

  hjem.users.primaryUser.files = {
    ".config/vicinae/settings.json".text = builtins.toJSON {
      "$schema" = "https://vicinae.com/schemas/config.json";
      "pop_to_root_on_close" = true;
      "encrypt_sensitive_data" = true;
      "favicon_service" = "google";
      "font" = {
        "rendering" = "qt";
        "normal"."family" = "Outfit";
      };

      "theme" = {
        "light" = {
          "name" = "libadwaita-dark";
          "icon_theme" = "Adwaita";
        };
        "dark" = {
          "name" = "libadwaita-dark";
          "icon_theme" = "Adwaita";
        };
      };

      "launcher_window" = {
        "opacity" = 0.95;
        "client_side_decorations"."enabled" = true;
        "compact_mode"."enabled" = true;
      };

      "providers"."clipboard"."preferences" = {
        "eraseOnStartup" = true;
        "ignorePasswords" = true;
        "monitoring" = true;
      };
    };

    # Autostart
    ".config/autostart/vicinae.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Vicinae
      Exec=${pkgs.vicinae}/bin/vicinae server
      X-GNOME-Autostart-enabled=true
    '';
  };
}
