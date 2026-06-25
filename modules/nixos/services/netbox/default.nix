{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.netbox;
in {
  options.ikl.services.netbox = with types; {
    enable = mkBoolOpt false "Whether or not to enable Netbox.";
    package = mkOpt package pkgs.netbox "Netbox package to use.";
    vhost = mkOpt str "" "vHost used for Netbox. e.g. netbox.example.com";
    acme.enable = mkBoolOpt true "Whether or not to enable ACME.";
    sslCertificate = mkOpt str "" "Path to SSL certificate.";
    sslCertificateKey = mkOpt str "" "Path to SSL certificate key.";
    apiTokenPeppersFile = mkOpt str "/data/secrets/netboxPepper" "Path to pepper file.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];

    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    virtualisation.oci-containers = {
      containers = {
        netbox = {
          image = "netboxcommunity/netbox:latest";
          environment = {
            DB_HOST = "postgres";
            DB_NAME = "netbox";
            DB_USER = "netbox";
            DB_WAIT_DEBUG = "1";
            REDIS_CACHE_DATABASE = "1";
            REDIS_CACHE_HOST= "valkey-cache";
            REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY = "false";
            REDIS_CACHE_SSL = "false";
            REDIS_DATABASE = "0";
            REDIS_HOST = "valkey";
            REDIS_INSECURE_SKIP_TLS_VERIFY = "false";
            REDIS_SSL = "false";
          };
          environmentFiles = [
            "/data/secrets/postgres_password"
            "/data/secrets/netboxSecret"
          ];
          dependsOn = [
            "postgres"
            "valkey"
            "valkey-cache"
          ];
          ports = [
            "127.0.0.1:8080:8080"
          ];
          pull = "newer";
          volumes = [
            "/data/netbox/config:/etc/netbox/config:z,ro"
            "/data/netbox/media:/opt/netbox/netbox/media:rw"
            "/data/netbox/reports:/opt/netbox/netbox/reports:rw"
            "/data/netbox/scripts:/opt/netbox/netbox/scripts:rw"
          ];
        };
        postgres = {
          image = "docker.io/postgres:18-alpine";
          environment = {
            POSTGRES_DB = "netbox";
            POSTGRES_USER = "netbox";
          };
          environmentFiles = [
            "/data/secrets/postgres_password"
          ];
          volumes = [
            "/data/netbox/database:/var/lib/postgresql"
            "/mnt/resource:/data"
          ];
        };
        valkey = {
          image = "docker.io/valkey/valkey:9.0-alpine";
          cmd = [
            "--appendonly yes"
          ];
          volumes = [
            "/data/netbox/valkey:/data"
          ];
        };
        valkey-cache = {
          image = "docker.io/valkey/valkey:9.0-alpine";
          volumes = [
            "/data/netbox/valkey-cache:/data"
          ];
        };
      };
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts."${cfg.vhost}" = {
        enableACME = cfg.acme.enable;
        sslCertificate = cfg.sslCertificate;
        sslCertificateKey = cfg.sslCertificateKey;
        forceSSL = true;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
    };
  };
}
