{ lib, ... }:

let
  inherit (import ./_utils.nix { inherit lib; }) int32_t mkDconf;
in {
  programs.dconf.profiles.user.databases = mkDconf { lockAll = true; } {
    # Just Perfection
    "org/gnome/shell/extensions/just-perfection" = {
      theme = false;
      top-panel-position = int32_t 1;
      notification-banner-position = int32_t 4;
      support-notifier-type = int32_t 0;
    };

    # Blur My Shell
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      whitelist = [ "com.mitchellh.ghostty" ];
      sigma = int32_t 30;
      opacity = int32_t 255;
      static-blur = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = true;
      static-blur = false;
      unblur-in-overview = true;
      sigma = int32_t 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/overview".style-components = int32_t 2;

    # Bluetooth Battery Meter
    "org/gnome/shell/extensions/Bluetooth-Battery-Meter" = {
      modify-quick-settings = true;
      popup-in-quick-settings = true;
      indicator-type = int32_t 2;
      enable-multi-indicator-mode = true;
      enable-tooltip = false;

      level-indicator-type = int32_t 0;
      level-bar-position = int32_t 1;
      level-indicator-color = int32_t 0;
      circle-widget-color = int32_t 1;

      enable-galaxy-buds-device = true;
    };

    # User Themes
    "org/gnome/shell/extensions/user-theme" = {
      name = "panel-fix";
    };
  };

  # hjem.users.primaryUser.files.".themes/panel-fix/gnome-shell/gnome-shell.css".text = ''
  #   @import url("${pkgs.gnome-shell}/share/gnome-shell/theme/gnome-shell.css");
  #
  #   #panel .panel-button,
  #   #panel .panel-button .system-status-icon {
  #     color: #222222;
  #   }
  #
  #   .workspace-dot {
  #     background-color: #222222;
  #   }
  # '';
}
