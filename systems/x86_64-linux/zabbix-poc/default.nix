{ lib, pkgs, modulesPath, ... }:
with lib;
with lib.ikl; {
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/virtualisation/azure-common.nix")
  ];

  boot.loader.grub = {
    enable = true;
    devices = lib.mkForce [ "/dev/sda" ];
  };

  networking.hostName = "zabbix-poc";

  time.timeZone = "Europe/London";

  fileSystems."/" = lib.mkForce
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=45%" "mode=755" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-label/nix";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  fileSystems."/data" =
    { device = "/dev/disk/by-label/data";
      neededForBoot = true;
      fsType = "ext4";
    };

  swapDevices =
    [
      { device = "/dev/disk/by-label/swap"; }
    ];

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "uk";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [
    age
    vim
    wget
    git
  ];

  users.users.italik.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsLgcBUEXCh7HVci+khRvtvVNpsPo7lfw8rDzo5zU4l"
  ];


  ikl = {
    services = {
      postgresql.enable = true;
      zabbix-server.enable = true;
    };
    system = {
      autoUpgrade.enable = true;
      azure.enable = true;
      impermanence.enable = true;
      ssh.enable = true;
      users.enable = true;
    };
  };

  system.stateVersion = "24.11";
}
