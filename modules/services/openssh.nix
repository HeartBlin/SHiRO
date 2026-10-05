{
  services.openssh = {
    enable = true;
    openFirewall = false;
    listenAddresses = [
      {
        addr = "10.100.0.1";
        port = 22;
      }
      {
        addr = "[fd71:3362:beef:1::1]";
        port = 22;
      }
    ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      X11Forwarding = false;
    };
  };

  systemd.services.sshd = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };
}
