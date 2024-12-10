{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.netbox;
in {
  options.ikl.services.netbox = with types; {
    enable = mkBoolOpt false "Whether or not to enable Netbox.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];

    services.netbox = {
      enable = true;
      listenAddress = "0.0.0.0";
      secretKeyFile = "/data/secrets/netboxSecret";
    };
    
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "alerts@italik.co.uk";
    # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        "/var/lib/acme"
        "/var/lib/netbox"
      ];
    };
  };
}
