# Only edit this file if you know what you are doing
# Please consult the application configuration *FOR THE VERSION YOU ARE CURRENTLY RUNNING*
# These options were written for v2.5.6
# The GitHub repo is located at drakkan/sftpgo
# The configuration file these options are based on is found at
# https://github.com/drakkan/sftpgo/blob/main/docs/full-configuration.md
# Again, please consult the above configuration documentation before changing anything below
#
# Options are mapped to Nix configuration by the Nix Project
# Options *must* match the data type defined in the configuration documentation
# Additional options can be found here: https://search.nixos.org/options
# You MUST ensure the Nix options you use match the configuration version defined in the root flake
#
# This file was written by Ben Standerline
# The last change was by Ben Standerline on 2024-04-02
{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.sftpgo;
in {
  options.ikl.services.sftpgo = with types; {
    enable = mkBoolOpt false "Whether or not to enable SFTPGo.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];
    services.sftpgo = {
      enable = true;
      settings = {
        common = {
          idle_timeout = 15;
          upload_mode = 0;
          actions = {
            execute_on = [ ];
            execute_sync = [ ];
            hook = "";
          };
          setstat_mode = 1;
          rename_mode = 0;
          resume_max_size = 0;
          # temp_path = "/path/to/temp/";
          proxy_protocol = 1;
          proxy_allowed = [ "127.0.0.1" ];
          proxy_skipped = [ ];
          startup_hook = "";
          post_connect_hook = "";
          post_disconnect_hook = "";
          data_retention_hook = "";
          max_total_connections = 500;
          max_per_host_connections = 50;
          allowlist_status = 0;
          allow_self_connections = 0;
          defender = {
            enabled = true;
            driver = "memory";
            ban_time = 30;
            ban_time_increment = 50;
            threshold = 15;
            score_invalid = 2;
            score_valid = 1;
            score_limit_exceeded = 3;
            score_no_auth = 1;
            observation_time = 30;
            entries_soft_limit = 100;
            entries_hard_limit = 200;
          };
          rate_limiters = [];
        };
        sftpd = {
          bindings = [
            { port = 22; address = ""; apply_proxy_config = true; }
          ];
          max_auth_tries = 6;
          banner = "Italik SFTP ready";
          host_keys = [
            "/var/lib/sftpgo/id_ecdsa"
            "/var/lib/sftpgo/id_ed25519"
            "/var/lib/sftpgo/id_rsa"
          ];
          host_certificates = [];
          host_key_algorithms = [
            "rsa-sha2-512"
            "rsa-sha2-256"
            "ecdsa-sha2-nistp256"
            "ecdsa-sha2-nistp384"
            "ecdsa-sha2-nistp521"
            "ssh-ed25519"
          ];
          kex_algorithms = [
            "curve25519-sha256"
            "ecdh-sha2-nistp256"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp521"
            "diffie-hellman-group14-sha256"
            "diffie-hellman-group-exchange-sha256"
          ];
          ciphers = [
            "aes128-gcm@openssh.com"
            "aes256-gcm@openssh.com"
            "chacha20-poly1305@openssh.com"
            "aes128-ctr"
            "aes192-ctr"
            "aes256-ctr"
          ];
          macs = [
            "hmac-sha2-256-etm@openssh.com"
            "hmac-sha2-256"
          ];
          public_key_algorithms = [
            "ecdsa-sha2-nistp256"
            "ecdsa-sha2-nistp384"
            "ecdsa-sha2-nistp521"
            "rsa-sha2-512"
            "rsa-sha2-256"
            "ssh-ed25519"
            "sk-ssh-ed25519@openssh.com"
            "sk-ecdsa-sha2-nistp256@openssh.com"
          ];
          trusted_user_ca_keys = [];
          revoked_user_certs_file = "";
          login_banner_file = "";
          enabled_ssh_commands = "";
          keyboard_interactive_authentication = true;
          keyboard_interactive_auth_hook = "";
          password_authentication = true;
          folder_prefix = "";
        };
        ftpd = {
          bindings = [
            {
              port = 0;
              address = "";
              apply_proxy_config = true;
              tls_mode = 0;
              tls_session_reuse = 0;
              certificate_file = "";
              certificate_ke_file = "";
              min_tls_version = 12;
              force_passive_ip = "";
              passive_ip_overrides = [
                # { networks = [ "" ]; ip = ""; }
              ];
              passive_host = "";
              client_auth_type = 0;
              tls_cipher_suites = []; # List of str
              passive_connections_security = 0;
              active_connections_security = 0;
              debug = false;
            }
          ];
          banner = "Italik FTP ready";
          banner_file = "";
          active_transfers_port_non_20 = true;
          passive_port_range = { start = 50000; end = 50100; };
          disable_active_mode = false;
          enable_site = false;
          hash_support = 0;
          combine_support = 0;
          certificate_file = "";
          certificate_key_file = "";
          ca_certificates = []; # List of str
          ca_revocation_lists = []; # List of str
        };
        webdavd = {
          bindings = [
            {
              port = 0;
              address = "";
              enable_https = false;
              certificate_file = "";
              certificate_key_file = "";
              min_tls_version = 12;
              client_auth_type = 0;
              tls_cipher_suits = []; # List of str
              tls_protocols = [
                "http/1.1"
                "h2"
              ];
              prefix = "";
              proxy_allowed = "";
              client_ip_proxy_header = "";
              client_ip_header_depth = 0;
              disable_www_auth_header = false;
            }
          ];
          certificate_file = "";
          certificate_key_file = "";
          ca_certificates = []; # List of str
          ca_revocation_lists = []; # List of str
          cors = {
            enabled = false; # MUST BE ENABLED IF USING WEBDAVD
            allowed_origins = []; # List of str
            allowed_methods = []; # List of str
            allowed_headers = []; # List of str
            exposed_headers = []; # List of str
            allow_credentials = false;
            max_age = 0;
            options_passthrough = false;
            options_success_status = 0;
            allow_private_network = false;
          };
          cache = {
            users = { expiration_time = 0; max_size = 50; };
            mime_types = {
              enabled = true;
              max_size = 1000;
              custom_mappings = [
                # { ext = ""; mime = ""; }
              ];
            };
          };
        };
        data_provider = {
          driver = "bolt";
          name = "/var/lib/sftpgo/sftpgo.db";
          host = "";
          #port = 0;
          username = "";
          username_file = "";
          password = "";
          password_file = "";
          #sslmode = 0;
          root_cert = "";
          disable_sni = false;
          target_session_attrs = "any";
          client_cert = "";
          client_key = "";
          connection_string = "";
          sql_tables_prefix = "sftpgo_";
          track_quota = 1;
          delayed_quota_update = 0;
          pool_size = 0;
          users_base_dir = "/var/lib/sftpgo/homes/";
          actions = {
            execute_on = []; # List of str
            execute_for = []; # List of str
            hook = "";
          };
          external_auth_hook = "";
          external_auth_scope = 0;
          credentials_path = "";
          pre_login_hook = "";
          post_login_hook = "";
          check_password_hook = "";
          check_password_scope = 0;
          password_hashing = {
            argon2_options = {
              memory = 131072;
              iterations = 2;
              parallelism = 2;
            };
            #bcrypt_options = { cost = 12; };
            algo = "argon2id";
          };
          password_validation = {
            admins = {
              min_entropy = 60;
            };
            users = {
              min_entropy = 50;
            };
          };
          password_caching = true;
          update_mode = 0;
          create_default_admin = false;
          naming_rules = 6;
          is_shared = 0;
          node = {
            host = "";
            port = 0;
            proto = "http";
          };
          backups_path = "/var/lib/sftpgo/backups";
        };
        httpd = {
          bindings = [
            {
              #port = 8080;
              address = "/run/sftpgo/httpd.sock";
              #address = "0.0.0.0";
              enable_web_admin = true;
              enable_web_client = true;
              enable_rest_api = false;
              enabled_login_methods = 12;
              # HTTPS provided by reverse proxy
              enable_https = false;
              #certificate_file = "";
              #certificate_key_file = "";
              #min_tls_version = 13;
              client_auth_type = 0;
              tls_cipher_suites = []; # Not configurable for TLS1.3
              tls_protocols = [ "http/1.1" "h2" ];
              proxy_allowed = [ "/run/sftpgo/httpd.sock" ]; # List of str
              client_ip_proxy_header = "X-Forwarded-For";
              client_ip_header_depth = 0;
              hide_login_url = 3;
              render_openapi = false;
              oidc = {
                config_url = "";
                client_id = "";
                client_secret = "";
                client_secret_file = "";
                redirect_base_url = "";
                username_field = "";
                scopes = [ "openid" "profile" "email" ];
                role_field = "";
                implicit_roles = false;
                custom_fields = []; # List of str
                insecure_skip_signature_check = false;
                debug = false;
              };
              security = {
                # Most of this is handled by the reverse proxy and is not needed
                # Please consult reverse proxy configuration and enable required settings
                # there instead of enabling this
                enabled = false;
                allowed_hosts = []; # List of str
                allowed_hosts_are_regex = false;
                hosts_proxy_eaders = []; # List of str
                https_redirect = false;
                https_host = "";
                https_proxy_headers = []; # List of key-value struct
                sts_seconds = 0;
                sts_include_subdomains = false;
                sts_preload = false;
                content_type_nosniff = false;
                content_security_policy = "";
                permissions_policy = "";
                cross_origin_opener_policy = "";
              };
              branding = {
                name = "Italik SFTP/FTP/FTPS Server";
                short_name = "Italik SFTP";
                favicon_path = "/branding/favicon.ico";
                logo_path = "/branding/logo.jpg"; # 250x250 please
                login_image_path = "/branding/login_image.png"; # 900x900 please
                disclaimer_name = "Disclaimer";
                disclaimer_path = "/branding/disclaimer.html";
                default_css = []; # List of str
                extra_css = []; # List of str
              };
            }
          ];
          #templates_path = "/var/lib/sftpgo/templates";
          #static_files_path = "/var/lib/sftpgo/static";
          #openapi_path = "";
          #web_root = "";
          certificate_file = "";
          certificate_key_file = "";
          ca_certificates = []; # List of str
          ca_revocation_lists = []; # List of str
          signing_passphrase = ""; # Empty will regenerate on each launch
          signing_passphrase_file = "";
          token_validation = 0;
          max_upload_file_size = 536870912; # 512M
          cors = {
            enabled = true;
            allowed_origins = []; # List of str
            allowed_methods = []; # List of str
            allowed_headers = []; # List of str
            exposed_headers = []; # List of str
            max_age = 5;
            options_passthrough = false;
            options_success_status = 204;
            allow_private_network = false;
          };
          setup = {
            installation_code = "!sxheT!iqbx655w#aB@G"; # Only used for installation
            installation_code_hint = "Installation code";
          };
          hide_support_link = true;
        };
        telemetry = {
          bind_port = 0;
          bind_address = "/run/sftpgo/telemetry.sock";
          enable_profiler = false;
          auth_user_file = "";
          certificate_file = "";
          certificate_key_file = "";
          min_tls_version = 13;
          tls_cipher_suites = []; # List of str
          tls_protocols = [ "http/1.1" "h2" ];
        };
        http = {
          timeout = 10;
          retry_wait_min = 5;
          retry_wait_max = 600;
          retry_max = 20;
          ca_certificates = []; # List of str
          certificates = [
            #{ cert = ""; key = ""; }
          ];
          skip_tls_verify = false;
          headers = [
            #{ key = ""; value = ""; url = ""; }
          ];
        };
        command = {
          timeout = 30;
          env = []; # List of str
          commands = [
            #{ path = ""; timeout = 0; env = [ "" ]; args = [ "" ]; hook = "" }
          ];
        };
        kms = {
          url = "";
          master_key = "";
          master_key_path = "";
        };
        mfa = {
          totp = [
            {
              name = "IKL-SFTPGO-TOTP-SHA1";
              issuer = "Italik SFTP";
              algo = "sha1";
            }
          ];
        };
        smtp = {
          host = "";
          port = 0;
          from = "";
          user = "";
          password = "";
          auth_type = 0;
          encryption = 0;
          domain = "";
          templates_path = "";
          debug = 0;
          oauth2 = {
            provider = 1;
            tenant = "";
            client_id = "";
            client_secret = "";
            refresh_token = "";
          };
        };
        plugins = [
#          {
#            type = "";
#            notifier_options = {
#              fs_events = []; # List of str
#              provider_events = []; # List of str
#              provider_objects = []; # List of str
#              log_events = []; # List of int
#              retry_max_time = 0;
#              retry_queue_max_size = 0;
#            };
#            kms_options = {
#              scheme = "";
#              encrypted_status = "";
#            };
#            auth_options = {
#              scope = 1;
#            };
#            cmd = "";
#            args = []; # List of str
#            sha256sum = "";
#            auto_mtls = true;
#            env_prefix = "";
#            env_vars = []; # List of str
#          }
        ];
      };
    };
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "alerts@italik.co.uk";
    users.users.nginx.extraGroups = [ "sftpgo" ];
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      clientMaxBodySize = "2G";

      virtualHosts."sftp.italikintra.net" = {
        enableACME = true;
        forceSSL = true;

        serverAliases = [ "cerberus.italikintra.net" ];

        locations."/" = {
          proxyPass = "http://unix:/run/sftpgo/httpd.sock";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };

        extraConfig = ''
          error_log /var/log/nginx/error.log;
          access_log /var/log/nginx/access.log;
        '';
      };
    };
   # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        "/var/lib/acme"
        {
          directory = "/var/lib/sftpgo/templates";
          user = "sftpgo";
          group = "sftpgo";
          mode = "0700";
        }
        {
          directory = "/var/lib/sftpgo/backups";
          user = "sftpgo";
          group = "sftpgo";
          mode = "0700";
        }
        {
          directory = "/var/lib/sftpgo/homes";
          user = "sftpgo";
          group = "sftpgo";
          mode = "0700";
        }
        {
          directory = "/var/lib/sftpgo/static";
          user = "sftpgo";
          group = "sftpgo";
          mode = "0700";
        }
        {
          directory = "/var/lib/sftpgo/vfolders";
          user = "sftpgo";
          group = "sftpgo";
          mode = "0700";
        }
      ];
      files = [
        "/var/lib/sftpgo/sftpgo.db"
        "/var/lib/sftpgo/id_ecdsa"
        "/var/lib/sftpgo/id_ed25519"
        "/var/lib/sftpgo/id_rsa"
      ];
    };
    systemd.tmpfiles.rules = [
      "d /run/sftpgo 0755 sftpgo sftpgo"
    ];
  };
}
