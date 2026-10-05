{ config, pkgs, ... }:

let
  wallpaperDir = "/home/${config.users.users.primaryUser.name}/Pictures/Wallpapers";

  switchWallpaper = pkgs.writeShellApplication {
    name = "switch-wallpaper";
    runtimeInputs = with pkgs; [ glib ];
    text = ''
      CURRENT_URI=$(gsettings get org.gnome.desktop.background picture-uri-dark)

      CURRENT_PATH=$(echo "$CURRENT_URI" | sed -E "s/^'file:\/\/(.*)'$/\1/")

      WP=$(find "${wallpaperDir}" -type f -iname "*.png" ! -path "$CURRENT_PATH" | shuf -n 1)

      if [ -z "$WP" ]; then
        WP=$(find "${wallpaperDir}" -type f -iname "*.png" | shuf -n 1)
      fi

      if [ -n "$WP" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$WP"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WP"
      else
        echo "No PNGs in ${wallpaperDir}" >&2
        exit 1
      fi
    '';
  };
in {
  environment.systemPackages = [ switchWallpaper ];
}
