{
  services.vaultwarden = {
    enable = true;
    backupDir = "/data/vaultwarden";
    config = {
      DOMAIN = "https://vault.heartblin.eu";
      SIGNUPS_ALLOWED = "false";
      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = "8222";
      ROCKET_LOG = "critical";
      SHOW_PASSWORD_HINT = "false";
      INVITATIONS_ALLOWED = "false";
    };
  };
}
