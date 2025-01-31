{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-proxy;
  pskPath = "/data/secrets/zabbix-proxy-psk.key";
  hostname = config.networking.hostName;
in {
  options.ikl.services.zabbix-proxy = with types; {
    enable = mkBoolOpt false "Whether or not to enable Zabbix Proxy.";
  };

  config = mkIf cfg.enable {
    # Allow SSH inbound
    networking.firewall.allowedTCPPorts = [ 22 ];

    # Configure Zabbix Proxy and allow Zabbix proxy inbound connections
    services.zabbixProxy = {
      enable = true;
      package = pkgs.zabbix70.proxy-pgsql;
      extraPackages = []; # List of pkgs
      settings = {
        TLSAccept = "psk";
        TLSConnect = "psk";
        TLSPSKFile = pskPath;
        TLSPSKIdentity = hostname;
      };
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

    # Installl the Zabbix Agent so we can monitor the proxy itself
    services.zabbixAgent = {
      enable = true;
      package = pkgs.zabbix70.agent2;
      openFirewall = true;
      server = "127.0.0.1";
    };

    # Configure the database that Zabbix proxy uses
    services.postgresql.ensureDatabases = [ "zabbix" ];
    services.postgresql.ensureUsers = [
      {
        name = "zabbix";
        ensureDBOwnership = true;
      }
    ];

    # Generate PSK file if it doesn't exist
    systemd.services.generate-zabbix-psk = {
      description = "Generate Zabbix PSK if it doesn't exist";
      wantedBy = [ "multi-user.target" ];
      before = [ "zabbix-proxy.service" ];
      script = ''
        set -eu
        [ ! -f ${pskPath} ] && openssl rand -hex 32 > ${pskPath} && chmod 400 ${pskPath} && chown zabbix:zabbix ${pskPath}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;
      };
    };
    
  };
}
