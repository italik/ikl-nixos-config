{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.grafana;
in {
  options.ikl.services.grafana = with types; {
    enable = mkBoolOpt false "Whether or not to enable Grafana.";
    vhost = mkOpt str "" "Primary FQDN.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];

    # Grafana config
    services.grafana = {
      enable = true;
      settings = {
        server = {
          protocol = "socket";
          enforce_domain = true;
          root_url = cfg.vhost;
        };
        database = {
          user = "grafana";
          type = "postgres";
          name = "grafana";
          host = "/run/postgresql";
        };
      };
    };

    # PostgreSQL config
    services.postgresql.ensureDatabases = [ "grafana" ];
    services.postgresql.ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];
    services.postgresql.authentication = ''
      local grafana grafana peer
    '';

    # Nginx config
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts."netbox.italikintra.net" = {
        enableACME = true;
        forceSSL = true;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://unix:/run/grafana/grafana.sock";
          proxyWebsockets = true;
        };
      };
    };
    users.users.nginx.extraGroups = [ "grafana" ];

    # ACME config
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "alerts@italik.co.uk";

    # Impermanence config
    environment.persistence."/data" = {
      directories = [
        "/var/lib/acme"
        "/var/lib/grafana"
      ];
    };
  };
}
