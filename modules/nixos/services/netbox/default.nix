{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.netbox;
in {
  options.ikl.services.netbox = with types; {
    enable = mkBoolOpt false "Whether or not to enable Netbox.";
    vhost = mkOpt str "" "vHost used for Netbox. e.g. netbox.example.com";
    acme.enable = mkBoolOpt true "Whether or not to enable ACME.";
    sslCertificate = mkOpt str "" "Path to SSL certificate.";
    sslCertificateKey = mkOpt str "" "Path to SSL certificate key.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];

    services.netbox = {
      enable = true;
      listenAddress = "[::1]";
      secretKeyFile = "/data/secrets/netboxSecret";
      settings = {
        ALLOWED_HOSTS = [ "[::1]" ];
        CSRF_TRUSTED_ORIGINS = [ "https://${cfg.vhost}" ];
      };
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts."${cfg.vhost}" = {
        enableACME = cfg.acme.enable;
        sslCertificate = cfg.sslCertificate;
        sslCertificateKey = cfg.sslCertificateKey;
        forceSSL = true;
        kTLS = true;
        locations."/" = {
          proxyPass = "http://[::1]:8001";
          proxyWebsockets = true;
        };
        locations."/static/".root = "/var/lib/netbox";
      };
    };
    users.users.nginx.extraGroups = [ "netbox" ];
    
    security.acme.acceptTerms = cfg.acme.enable;
    security.acme.defaults.email = mkIf cfg.acme.enable "alerts@italik.co.uk";
    # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        "/var/lib/netbox"
        "/var/lib/postgresql"
      ] ++ lib.optional cfg.acme.enable "/var/lib/acme";
    };
  };
}
