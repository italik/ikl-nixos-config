{ lib, pkgs, ... }:
with lib;
with lib.ikl; {
  ### Change only options below here

  networking = {
    hostName = "TSHZPXYSVPRD001";
    interfaces.eno1 = {
      ipv4.addresses = [
        {
          address = "10.1.2.3";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "10.1.2.254";
      interface = "eno1";
    };
    nameservers = [
      "10.1.2.2"
    ];
    useDHCP = false;
  };

  ### Change only options above here

  imports = with inputs; [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  time.timeZone = "Europe/London";

  services.timesyncd.servers = [
    "10.1.2.2"
  ];

  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=45%" "mode=755" ];
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext2";
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH76BeorE16J5TxpOeFVBrKNTHcFBarDQVCuEqq+2/hf IKL-ZBBXPXY-SSHKEY"
  ];


  ikl = {
    services = {
      postgresql.enable = true;
      zabbix-proxy.enable = true;
      zabbix-proxy.cacheSize = "64M";
      zabbix-proxy.splash.enable = true;
    };
    system = {
      autoUpgrade.enable = true;
      impermanence.enable = true;
      ssh.enable = true;
      users.enable = true;
    };
  };

  system.stateVersion = "25.05";
}
