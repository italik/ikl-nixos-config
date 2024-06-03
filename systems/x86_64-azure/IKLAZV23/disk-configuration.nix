{ inputs, ... }:
{
  disko.devices = {
    disk.system = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          bios = {
            name = "bios";
            priority = 1;
            size = "1M";
            type = "EF02";
          };
          boot = {
            name = "boot";
            priority = 2;
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            name = "swap";
            priority = 3;
            size = "8G";
            type = "swap";
            content = {
              type = "swap";
            };
          };
          nix = {
            name = "nix";
            priority = 4;
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
