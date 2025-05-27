{ lib, pkgs, ... }:
with lib;
with lib.ikl; {
  ### Change only options below here

  networking.hostName = "2PLANZPXYPR001";

  ### Change only options above here

  imports = with inputs; [
    ./hardware-configuration.nix
    (modulesPath + "/virtualisation/azure-common.nix")
  ];

  boot.loader.grub = {
    enable = true;
    devices = lib.mkForce [ "/dev/sda" ];
  };


  time.timeZone = "Europe/London";

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

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
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
      zabbix-proxy.splash.enable = true;
    };
    system = {
      autoUpgrade.enable = true;
      azure.enable = true;
      impermanence.enable = true;
      ssh.enable = true;
      users.enable = true;
    };
  };

  system.stateVersion = "25.05";
}
