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
        DebugLevel = 4;
        LogFile = lib.mkForce "/var/log/zabbix/zabbix_server.log";
        LogFileSize = lib.mkForce 16;
        LogType = lib.mkForce "file";
      };
    };

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
