{ pkgs, ... }:

{
  users.users.kiosk.isNormalUser = true;
  services.cage = {
    enable = true;
    extraArguments = [ "-s" ];
    user = "kiosk";
    program = builtins.concatStringsSep " " [
      "${pkgs.chromium}/bin/chromium"
      "--kiosk"
      "--ozone-platform=wayland"
      "--no-first-run"
      "--noerrdialogs"
      "--disable-infobars"
      "--disable-session-crashed-bubble"
      "--password-store=basic"
      "--hide-scrollbars"
      "http://[::1]:8101/system/92t2tf4vjx1pw3y"
    ];
  };

  systemd.services."cage-tty1" = {
    after = [ "beszel-hub.service" ];
    wants = [ "beszel-hub.service" ];
    serviceConfig.ExecStartPre = "${pkgs.bash}/bin/bash -c 'until ${pkgs.netcat}/bin/nc -z ::1 8100; do sleep 1; done'";
  };
}
