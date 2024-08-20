{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.postgresql;
in {
  options.ikl.services.postgresql = with types; {
    enable = mkBoolOpt false "Whether or not to enable PostgreSQL.";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      settings = {
        # Generated from https://pgtune.leopard.in.ua/
        max_connections = 500;
        shared_buffers = "2GB";
        effective_cache_size = "6GB";
        maintenance_work_mem = "512MB";
        checkpoint_completion_target = 0.9;
        wal_buffers = "16MB";
        default_statistics_target = 100;
        random_page_cost = 1.1;
        effective_io_concurrency = 200;
        work_mem = "2097kB";
        huge_pages = false;
        min_wal_size = "1GB";
        max_wal_size = "4GB";
      };
    };
    # Setup folders (see https://github.com/nix-community/impermanence)
    environment.persistence."/data" = {
      directories = [
        "/var/log"
        "/var/lib/postgresql"
      ];
    };
  };
}
