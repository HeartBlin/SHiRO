{ inputs, lib, pkgs, ... }:

let
  ttyConfig = {
    language = "en";

    term = "xterm-256color";

    font-family = "CaskaydiaCove Nerd Font Mono";
    font-style = "Italic";
    font-style-bold = "Bold Italic";
    font-style-italic = "Italic";
    font-style-bold-italic = "Bold Italic";
    font-feature = "+calt";
    font-size = 11;

    cursor-color = "#dadada";
    cursor-style = "block";
    cursor-style-blink = false;
    cursor-text = "#141b1e";
    cursor-click-to-move = true;

    shell-integration-features = "no-cursor";

    background-opacity = 0.90;

    background = "#141b1e";
    foreground = "#dadada";
    palette = [
      "0=#232a2d"
      "1=#e57474"
      "2=#8ccf7e"
      "3=#e5c76b"
      "4=#67b0e8"
      "5=#c47fd5"
      "6=#6cbfbf"
      "7=#b3b9b8"
      "8=#2d3437"
      "9=#ef7e7e"
      "10=#96d988"
      "11=#f4d67a"
      "12=#71baf2"
      "13=#ce89df"
      "14=#67cbe7"
      "15=#bdc3c2"
    ];

    window-padding-x = 10;
    window-padding-y = 10;
    window-padding-color = "extend";
  };
in {
  environment.systemPackages = [ inputs.kuro.packages.${pkgs.stdenv.hostPlatform.system}.ghostty-znver2 ];
  hjem.users.primaryUser.files.".config/ghostty/config".text = lib.generators.toKeyValue { listsAsDuplicateKeys = true; } ttyConfig;
  fonts.packages = [ pkgs.nerd-fonts.caskaydia-cove ];
  programs.fish.interactiveShellInit = ''
    if set -q GHOSTTY_RESOURCES_DIR
      source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    end
  '';
}
