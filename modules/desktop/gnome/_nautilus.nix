{ config, lib, pkgs, ... }:

let
  inherit (import ./_utils.nix { inherit lib; }) mkDconf;
in {
  environment.systemPackages = with pkgs; [
    nautilus
    sushi
    nautilus-python
  ];

  hjem.users.primaryUser.files.".config/gtk-3.0/bookmarks".text = ''
    file:///home/${config.users.users.primaryUser.name}/Documents Documents
    file:///home/${config.users.users.primaryUser.name}/Downloads Downloads
    file:///home/${config.users.users.primaryUser.name}/Music Music
    file:///home/${config.users.users.primaryUser.name}/Pictures Pictures
    file:///home/${config.users.users.primaryUser.name}/Public Public
    file:///home/${config.users.users.primaryUser.name}/Videos Videos

    file:///home/${config.users.users.primaryUser.name}/.steam/steam/steamapps/common/PAYDAY%202/mods Mods
    file:///home/${config.users.users.primaryUser.name}/.steam/steam/steamapps/common/PAYDAY%202/assets/mod_overrides Mod Overrides
  '';

  programs.dconf.profiles.user.databases = mkDconf { } {
    "org/gnome/nautilus/icon-view".captions = [
      "size"
      "none"
      "none"
    ];
  };
}
