let
  keys = import ./keys.nix;
  inherit (keys) Void Reason Finality;
  allWithBackup = [ Void Reason Finality ];
in {
  "beszel/env.age".publicKeys = allWithBackup;
  "ovh/dns.age".publicKeys = allWithBackup;
  "ovh/ddns-updater.json.age".publicKeys = allWithBackup;
  "restic/env.age".publicKeys = allWithBackup;
  "restic/health.age".publicKeys = allWithBackup;
  "nix-cache/signkey.age".publicKeys = allWithBackup;
  "nextcloud/admin.age".publicKeys = allWithBackup;
  "slskd/env.age".publicKeys = allWithBackup;
  "github/app-key.age".publicKeys = allWithBackup;
  "hydra/token.age".publicKeys = allWithBackup;
}
