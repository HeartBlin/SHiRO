{ config, pkgs, self, ... }:

{
  age.secrets = {
    restic-env = {
      file = "${self}/secrets/restic/env.age";
      owner = "root";
      mode = "0400";
    };

    healthchecks = {
      file = "${self}/secrets/restic/health.age";
      owner = "root";
      mode = "0400";
    };
  };

  services.restic.backups = let
    repository = "s3:https://s3.eu-central-lz-buh-a.cloud.ovh.net/heartblin";
    environmentFile = config.age.secrets.restic-env.path;
    initialize = true;

    prepare = name: backupDir: ''
      mkdir -p /data/${backupDir}
      if [ -d /data/${backupDir}/${name} ]; then
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /data/${backupDir}/${name}
      fi
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /data/${name} /data/${backupDir}/${name}
    '';

    cleanup = name: backupDir: ''
      if [ -d /data/${backupDir}/${name} ]; then
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /data/${backupDir}/${name}
      fi

      HC_PING="$(cat ${config.age.secrets.healthchecks.path})"
      HC_URL="https://hc-ping.com/$HC_PING/${name}"

      if [ "$SERVICE_RESULT" != "success" ]; then
        HC_URL="$HC_URL/fail"
      fi

      ${pkgs.systemd}/bin/journalctl "_SYSTEMD_INVOCATION_ID=$INVOCATION_ID" --no-pager \
        | tail -c 9000 \
        | ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 --data-binary @- "$HC_URL" > /dev/null
    '';
  in {
    vaultwarden = {
      inherit environmentFile initialize repository;
      paths = [ "/data/.snapshot-vaultwarden/vaultwarden" ];
      backupPrepareCommand = prepare "vaultwarden" ".snapshot-vaultwarden";
      backupCleanupCommand = cleanup "vaultwarden" ".snapshot-vaultwarden";

      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      checkOpts = [ "--with-cache" ];
      extraBackupArgs = [ "--compression=max" ];
    };

    music = {
      inherit environmentFile initialize repository;
      paths = [ "/data/.snapshot-music/music" ];
      backupPrepareCommand = prepare "music" ".snapshot-music";
      backupCleanupCommand = cleanup "music" ".snapshot-music";

      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      checkOpts = [ "--with-cache" ];
      extraBackupArgs = [ "--compression=max" ];
    };

    store = {
      inherit environmentFile initialize repository;
      paths = [ "/data/.snapshot-store/store" ];
      backupPrepareCommand = prepare "store" ".snapshot-store";
      backupCleanupCommand = cleanup "store" ".snapshot-stoer";

      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      checkOpts = [ "--with-cache" ];
      extraBackupArgs = [ "--compression=max" ];
    };
  };
}
