{ lib, pkgs, ... }:
with lib;
with lib.ikl; {
  imports = with inputs; [
    ./hardware-configuration.nix
    (modulesPath + "/virtualisation/azure-common.nix")
  ];

  boot.loader.grub = {
    enable = true;
    devices = lib.mkForce [ "/dev/sda" ];
  };

  networking.hostName = "IKLGFNAVMPRD001";

  time.timeZone = "Europe/London";

  fileSystems."/" = lib.mkForce
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=75%" "mode=755" ];
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

  sops.defaultSopsFile = ./secrets/IKLGFNAVMPRD001.yaml;
  sops.age.keyFile = "/data/secrets/age-keys.txt";
  sops.secrets = {
    zabbix-psk = {
      mode = "0440";
      owner = "zabbix-agent";
      group = "zabbix-agent";
    };
  };

  environment.systemPackages = with pkgs; [
    age
    vim
    wget
    git
  ];

  users.users.italik.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDoe+f9O3LdIXm+UL7pLDWWedmxoR2zK4QPu6yJNjAz iklgfnavmprd001"
  ];


  ikl = {
    services = {
      grafana = {
        enable = true;
        vhost = "grafana.italikintra.net";
      };
      postgresql.enable = true;
      zabbix-agent = {
        enable = true;
        server = "13.79.72.159";
        psk = {
          enable = true;
          identity = "IKLGFNAVMPRD001";
          file = "/run/secrets/zabbix-psk";
        };
        nginxStubStatus = true;
      };
    };
    system = {
      autoUpgrade.enable = true;
      azure.enable = true;
      impermanence.enable = true;
      ssh.enable = true;
      syslog.enable = true;
      users.enable = true;
    };
  };

  system.stateVersion = "25.05";
}
