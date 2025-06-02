{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.azure;
  waagent = pkgs.waagent.overridePythonAttrs (oldAttrs: rec {
    # Ensure Distutils (for Python 3.12) is on the build inputs
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
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
  };
}
