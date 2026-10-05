{ config, ... }:

{
  networking = {
    nftables.enable = true;
    networkmanager.enable = false;
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "en* eth*";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        IPv6PrivacyExtensions = "no";
      };

      ipv6AcceptRAConfig = {
        Token = "prefixstable";
        UseDNS = false;
      };

      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
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
