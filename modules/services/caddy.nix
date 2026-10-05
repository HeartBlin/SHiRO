{ config, pkgs, self, ... }:

let
  domain = "heartblin.eu";
  mTLS = x: ''
    tls {
      client_auth {
        mode require_and_verify
        trust_pool file {
          pem_file /etc/caddy/root.cert.pem
        }

        verifier revocation {
          mode crl_only
          crl_config {
            work_dir /var/lib/caddy/crl-workspace
            storage_type memory
            update_interval 1m
            signature_validation_mode verify

            trusted_signature_cert_file /etc/caddy/root.cert.pem
            trusted_signature_cert_file /etc/caddy/intermediate.cert.pem

            crl_file /etc/caddy/root.crl.pem
            crl_file /etc/caddy/intermediate.crl.pem
          }
        }
      }
    }

    ${x}
  '';
in {
  age.secrets.ovh-dns = {
    file = "${self}/secrets/ovh/dns.age";
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
    mode = "0440";
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.age.secrets.ovh-dns.path
  ];

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 443 ];
  };

  services.caddy = {
    enable = true;
    enableReload = true;
    package = pkgs.caddy.withPlugins {
      hash = "sha256-v8mcHaD7//j2S2wp/QJ0o50wmkwP6g+kb4LnJvFSeN0=";
      plugins = [
        "github.com/caddy-dns/ovh@v1.1.0"
        "github.com/gr33nbl00d/caddy-revocation-validator@v1.0.7"
      ];
    };

    globalConfig = ''
      grace_period 15s
      acme_dns ovh {
        endpoint {$OVH_ENDPOINT}
        application_key {$OVH_APPLICATION_KEY}
        application_secret {$OVH_APPLICATION_SECRET}
        consumer_key {$OVH_CONSUMER_KEY}
      }
    '';

    virtualHosts = {
      "hydra.${domain}".extraConfig = mTLS "reverse_proxy http://[::1]:3000";
      "files.${domain}".extraConfig = mTLS "reverse_proxy http://[::1]:8090";
      "media.${domain}".extraConfig = mTLS "reverse_proxy http://[::1]:8096";
      "vault.${domain}".extraConfig = mTLS "reverse_proxy http://[::1]:8222";
      "soul.${domain}".extraConfig = mTLS "reverse_proxy http://[::1]:5030";

      # Beszel Kiosk setup
      "info.${domain}".extraConfig = mTLS ''
        request_header -X-Beszel-User
        reverse_proxy http://[::1]:8100
      '';

      "http://[::1]:8101".extraConfig = ''
        bind ::1
        reverse_proxy http://[::1]:8100 {
          header_up X-Beszel-User kiosk@reason.local
        }
      '';
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/caddy/crl-workspace 0700 caddy caddy" ];
}
