{ inputs, lib, pkgs, ... }:

let
  inherit (import ./_utils.nix { inherit lib; }) int32_t string tuple emptyArray mkDconf;

  # Vars
  cursor-theme = "Bibata-Modern-Ice";
  cursor-size = int32_t 24;

  # Extensions
  extensions = with pkgs.gnomeExtensions;
    [
      caffeine
      just-perfection
      vicinae
      blur-my-shell
      no-overview
      bluetooth-battery-meter
      user-themes
    ]
    ++ (with inputs.kuro.packages.${pkgs.stdenv.system}; [
      static-workspace-background
      gradia-capture
    ]);
in {
  imports = [
    ./_binds.nix
    ./_extensions.nix
    ./_nautilus.nix
    ./_vicinae.nix
    ./_wallpaper.nix
  ];

  # Get GNOME
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  environment = {
    # Remove most things tbh
    gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany
      geary
      yelp
      snapshot
      simple-scan
      totem
      evince
      gnome-contacts
      gnome-maps
      decibels
      gnome-text-editor
      gnome-console
    ];

    sessionVariables = {
      GI_TYPELIB_PATH = [ "${inputs.kuro.packages.${pkgs.stdenv.system}.gnome-rounded-blur}/lib/girepository-1.0" ];
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    # Get icons/cursors and extensions
    systemPackages = with pkgs;
      [
        bibata-cursors
        adwaita-icon-theme
      ]
      ++ extensions;
  };

  programs.dconf = {
    enable = true;
    profiles = {
      gdm.databases = mkDconf { lockAll = true; } {
        "org/gnome/desktop/interface" = {
          inherit cursor-theme cursor-size;
        };
      };

      user.databases = mkDconf { lockAll = true; } {
        # Interface
        "org/gnome/desktop/interface" = {
          inherit cursor-theme cursor-size;
          color-scheme = "prefer-dark";
          accent-color = "blue";
          enable-hot-corners = false;
        };

        # Peripherals in general
        "org/gnome/desktop/peripherals/touchpad".natural-scroll = false;
        "org/gnome/desktop/peripherals/mouse".natural-scroll = false;
        "org/gnome/desktop/input-sources".sources = [ (tuple [ "xkb" "ro" ]) ];

        # Things
        "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
        "org/gnome/settings-daemon/plugins/power".power-button-action = "interactive";

        "org/gnome/shell" = {
          # Extensions
          disable-user-extensions = false;
          enabled-extensions = map (ext: ext.extensionUuid) extensions;

          # Nothing in dock
          favorite-apps = emptyArray string;

          # Always show log out
          always-show-log-out = true;
        };

        "org/gnome/mutter".attach-modal-dialogs = false;
      };
    };
  };

  # X11 cursor fix
  hjem.users.primaryUser.files.".icons/${cursor-theme}".source = "${pkgs.bibata-cursors}/share/icons/${cursor-theme}";
}
