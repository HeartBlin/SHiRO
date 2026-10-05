{
  disko.devices.disk = {
    os = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA20450EZM512A";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          swap = {
            size = "24G";
            content = {
              type = "swap";
              discardPolicy = "both";
              resumeDevice = true;
            };
          };

          os = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-L" "os" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "/log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "/var-lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };

    data = {
      type = "disk";
      device = "/dev/disk/by-id/ata-KINGSTON_SKC600512G_50026B7784CD5F58";
      content = {
        type = "gpt";
        partitions = {
          cryptdata = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-L" "data" ];
              mountpoint = "/data";
              mountOptions = [ "noatime" "compress=zstd" ];
              subvolumes = {
                "/music" = {
                  mountpoint = "/data/music";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "/store" = {
                  mountpoint = "/data/store";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                "/vaultwarden" = {
                  mountpoint = "/data/vaultwarden";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
