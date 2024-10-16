{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-proxy;
in {
  options.ikl.services.zabbix-proxy = with types; {
    enable = mkBoolOpt false "Whether or not to enable Zabbix Proxy.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.zabbixProxy = {
      enable = true;
      package = pkgs.zabbix70.proxy-pgsql;
      extraPackages = []; # List of pkgs
      database = {
        createLocally = true;
        host = ""; # Use Unix socket
        name = "zabbix";
        user = "zabbix";
        socket = "/run/postgresql";
        type = "pgsql";
        port = 5432;
      };
      openFirewall = true;
      server = "zabbix.italikintra.net";
    };

    services.zabbixAgent = {
      enable = true;
      package = pkgs.zabbix70.agent2;
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
    
  };
}
