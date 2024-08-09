{ lib, pkgs, ... }:
with lib;
with lib.ikl; {
  imports = with inputs; [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    devices = lib.mkForce [ "/dev/sda" ];
  };

  networking.hostName = "IKLAZV23";

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

  sops.defaultSopsFile = ./secrets/IKLAZV23.yaml;
  sops.age.keyFile = "/data/secrets/age-keys.txt";
  sops.secrets = {
    snmpd-string = {
      mode = "0440";
      owner = "root";
      group = "root";
    };
    snmpd-ip = {
      mode = "0440";
      owner = "root";
      group = "root";
    };
  };

  environment.systemPackages = with pkgs; [
    age
    vim
    wget
    git
  ];

  users.users.italik.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGZchNdZjwvX4Ie0ICn/+C9S11m71J0aCxOoD6gBXni RDM--IKLAZV23"
  ];


  ikl = {
    services = {
      sftpgo.enable = true;
    };
    system = {
      azure.enable = true;
      impermanence.enable = true;
      ssh.enable = true;
      users.enable = true;
    };
  };

  # Override SSH port as SFTPGo uses port 22
  services.openssh.ports = lib.mkForce [ 7356 ];
}
