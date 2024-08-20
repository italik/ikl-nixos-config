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
      extraPackages = []; # List of pkgs
      database = {
        createLocally = false;
        host = ""; # Use Unix socket
        name = "zabbix";
        user = "zabbix";
        socket = "/run/postgresql";
        type = "pgsql";
      };
      openFirewall = true;
      settings = {};
    };

    services.zabbixWeb = {
      enable = true;
      database = {
        host = ""; # Use Unix socket
        name = "zabbix";
        user = "zabbix";
        socket = "/run/postgresql";
        type = "pgsql";
      };
      virtualHost = {
        adminAddr = "support@italik.co.uk";
        enableACME = true;
        forceSSL = true;
        hostName = "zabbix.italikintra.net";
      };
    };

    services.zabbixAgent = {
      enable = true;
      openFirewall = true;
      server = "127.0.0.1";
    };

    services.postgresql.ensureDatabases = [ "zabbix" ];
    services.postgresql.ensureUsers = [
      {
        name = "zabbix";
        ensureDBOwnership = true;
      }
    ];
    
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "alerts@italik.co.uk";
    # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        "/var/lib/acme"
      ];
    };
  };
}
