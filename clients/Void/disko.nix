{
  disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX1W519812T";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        swap = {
          size = "20G";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true;
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            settings = {
              allowDiscards = true;
              crypttabExtraOpts = [ "fido2-device=auto" ];
            };

            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
              mountOptions = [
                "defaults"
                "pquota"
              ];
            };
          };
        };
      };
    };
  };
}
