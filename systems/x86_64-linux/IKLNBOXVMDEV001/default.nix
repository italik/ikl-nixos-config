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

  networking.hostName = "IKLNBOXVMDEV001";

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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6kQzs/PipbCEaWNGDl6upbDguW9WwE4gHe4I1MCr58"
  ];


  ikl = {
    services = {
      netbox = {
        enable = true;
        vhost = "netboxdev.italikintra.net";
        acme.enable = false;
        sslCertificate = "/data/secrets/certificate.pem";
        sslCertificateKey = "/data/secrets/certificate.key";
      };
      zabbix-agent = {
        enable = true;
        server = "13.79.72.159";
        psk = {
          enable = true;
          identity = "IKLNBOXVMDEV001";
          file = "/data/secrets/zabbix-psk";
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
  system.stateVersion = "25.11";
}
