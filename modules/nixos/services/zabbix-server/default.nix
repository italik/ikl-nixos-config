{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-server;
in {
  options.ikl.services.zabbix-server = with types; {
    enable = mkBoolOpt false "Whether or not to enable Zabbix Server.";
    syslog.enable = mkBoolOpt false "Whether or not to enable syslog forwarding of Zabbix server logs.";
    syslog.server = mkOpt str "" "Syslog server to send Zabbix server logs to.";
    syslog.port = mkOpt port "" "Port for syslog server.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];
    services.zabbixServer = {
      enable = true;
      package = pkgs.zabbix70.server;
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
      settings = {
        AlertScriptsPath="${pkgs.ikl.zabbix-alert-scripts}/bin";
        ValueCacheSize = "100M";
        CacheSize = "128M";
        DebugLevel = 3;
        LogFile = lib.mkForce "/var/log/zabbix/zabbix_server.log";
        LogFileSize = lib.mkForce 16;
        LogType = lib.mkForce "file";
      };
    };

    services.rsyslogd.extraConfig = mkIf cfg.syslog.enable ''
      module(load="imfile")
      input(type="imfile"
            File="/var/log/zabbix/zabbix_server.log"
            Tag="zabbix_server"
            Severity="info"
            Facility="local0")
      if $syslogfacility-text == "local0" then {
        action(
          type="omfwd"
          protocol="tcp"
          target="${cfg.syslog.server}"
          port="${builtins.toString cfg.syslog.port}"
          action.resumeRetryCount="100"
          queue.type="linkedList"
          queue.size="10000"
        )
        stop
      }
    '';

    services.zabbixWeb = {
      enable = true;
      package = pkgs.zabbix70.web;
      extraConfig = ''
      $SSO['IDP_CERT'] = "/data/secrets/zabbix_sso_idp.cert";
      $SSO['SETTINGS'] = ['security' => ['requestedAuthnContext' => false]];
      '';
      database = {
        host = ""; # Use Unix socket
        name = "zabbix";
        user = "zabbix";
        socket = "/run/postgresql";
        type = "pgsql";
      };
      httpd.virtualHost = {
        adminAddr = "support@italik.co.uk";
        enableACME = true;
        forceSSL = true;
        hostName = "zabbix.italikintra.net";
      };
    };

    services.zabbixAgent = {
      enable = true;
      package = pkgs.zabbix70.agent2;
      openFirewall = true;
      server = "127.0.0.1";
      settings = {
        ServerActive = "127.0.0.1";
        Hostname = "Zabbix server";
      };
    };

    services.postgresql.ensureDatabases = [ "zabbix" ];
    services.postgresql.ensureUsers = [
      {
        name = "zabbix";
        ensureDBOwnership = true;
      }
    ];
    services.postgresql.authentication = ''
      local zabbix  zabbix  peer
    '';
    
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "alerts@italik.co.uk";
    # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        {
          directory = "/var/lib/zabbix";
          user = "zabbix";
          group = "zabbix";
          mode = "0700";
        }
        {
          directory = "/var/log/zabbix";
          user = "zabbix";
          group = "zabbix";
          mode = "0700";
        }
        "/var/lib/acme"
      ];
    };
  };
}
