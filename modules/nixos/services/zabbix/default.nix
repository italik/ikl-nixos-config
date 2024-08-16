{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-server;
in {
  options.ikl.services.zabbix-server = with types; {
    enable = mkBoolOpt false "Whether or not to enable Zabbix Server.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];
    services.zabbixServer = {
      enable = true;
      database = {
        createLocally = false;
        
      };
      listen = {
        ip = "";
        port = "";
      };
      openFirewall = true;
      settings = {};
    };
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "alerts@italik.co.uk";
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
    };
    # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        "/var/log"
        "/var/lib/acme"
      ];
    };
  };
}
