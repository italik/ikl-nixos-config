{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.azure;
  waagent = pkgs.waagent.overridePythonAttrs (oldAttrs: rec {
    # Ensure Distutils (for Python 3.12) is on the build inputs
    dependencies = oldAttrs.dependencies ++ [
      pkgs.python312Packages.distutils
    ];
  });
in {
  options.ikl.system.azure = with types; {
    enable = mkBoolOpt false "Whether or not to enable Azure extensions.";
    verboseLogging = mkBoolOpt false "Whether or not to enable verbose logging.";
    mountResourceDisk = mkBoolOpt true "Whether the agent should format (ext4) and mount the resource disk to /mnt/resource.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 68 ];

    # waagent should be enabled by including azure-common in the system imports
    services.waagent = {
      settings = {
        Logs.Verbose = cfg.verboseLogging;
        ResourceDisk.Format = cfg.mountResourceDisk;
      };
      package = waagent;
      extraPackages = with pkgs; [
        gawk
        gnupg
        which
      ];
    };

    environment.persistence."/data" = {
      directories = [
        "/var/lib/waagent"
      ];
    };
    # Workaround buggy Azure Linux agent
    systemd.timers.create_waagent_symlinks = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        Unit = "create_waagent_symlinks.service";
      };
    };
    systemd.services.create_waagent_symlinks = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ln -sf /run/current-system/sw/bin/base64 /usr/bin/base64
        ln -sf ${pkgs.openssl}/bin/openssl /usr/bin/openssl
        ln -sf /run/wrappers/bin/mount /bin/mount
        mkdir -p /usr/sbin
        ln -sf ${waagent}/bin/waagent /usr/sbin/waagent
      '';
    };
  };
}
