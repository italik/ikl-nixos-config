{ lib, pkgs, ... }:
with lib;
with lib.ikl; {
  disko.devices = {
    disk = {
      system = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            boot = {
              label = "BOOT";
              name = "BOOT";
              size = "1G";
              priority = 2;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            nix = {
              label = "nix";
              name = "nix";
              size = "16G";
              priority = 3;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
            data = {
              label = "data";
              name = "data";
              size = "100%";
              priority = 4;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/data";
              };
            };
          };
        };
      };
    };
  };
}
