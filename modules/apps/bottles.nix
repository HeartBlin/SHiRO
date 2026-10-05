{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.bottles.override { removeWarningPopup = true; })
  ];
}
