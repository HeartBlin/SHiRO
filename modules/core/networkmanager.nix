{ config, lib, ... }:

{
  networking = {
    nftables.enable = true;
    dhcpcd.wait = "background";
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      plugins = lib.mkForce [ ];
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "supported";
      DNSOverTLS = "opportunistic";
      DNS = config.networking.nameservers;
      FallbackDNS = [
        "8.8.8.8#dns.google"
        "8.8.4.4#dns.google"
        "2001:4860:4860::8888#dns.google"
        "2001:4860:4860::8844#dns.google"
      ];
    };
  };
}
