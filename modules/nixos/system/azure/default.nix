{ options, config, lib, pkgs, modulesPath, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.azure;
  waagent = (pkgs.waagent.override {
    python3 = pkgs.python39;
  });
in {
  options.ikl.system.azure = with types; {
    enable = mkBoolOpt false "Whether or not to enable Azure extensions.";
    verboseLogging = mkBoolOpt false "Whether or not to enable verbose logging.";
    mountResourceDisk = mkBoolOpt true "Whether the agent should format (ext4) and mount the resource disk to /mnt/resource.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 68 ];

    services.logrotate = {
      enable = true;
      settings."/var/log/waagent.log" = {
        compress = true;
        frequency = "monthly";
        rotate = 6;
      };
    };

    security.sudo.extraConfig = ''
      #includedir /etc/sudoers.d
    '';

    environment.persistence."/data" = {
      directories = [
        "/var/lib/waagent"
      ];
    };

    imports = with inputs; [
      (modulesPath + "/virtualisation/azure-common.nix")
    ];
  };
}
