{ config, inputs, ... }:

{
  imports = [ inputs.hjem.nixosModules.default ];
  config = let
    userName = config.users.users.primaryUser.name;
    userHome = config.users.users.primaryUser.home;
  in {
    users.users.primaryUser = {
      isNormalUser = true;
      initialPassword = "changeme";
      extraGroups = [ "wheel" "networkmanager" ];
    };

    hjem = {
      cli.package = inputs.hjem.packages."x86_64-linux".hjem;
      linker = inputs.hjem.packages."x86_64-linux".hjem;
      clobberByDefault = true;
      users.primaryUser = {
        enable = true;
        user = userName;
        directory = userHome;
      };
    };
  };
}
