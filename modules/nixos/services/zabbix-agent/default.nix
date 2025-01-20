{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-agent;
in {
  options.ikl.services.zabbix-agent = with types; {
    enable = mkBoolOpt false "Whether or not to enable Zabbix Agent.";
    server = mkOpt str "zabbix.italikintra.net" "Zabbix Server or Proxy to connect to for Passive checks.";
    serverActive = mkOpt str cfg.server "Zabbix Server or Proxy to connect to for Active checks";
  };

  config = mkIf cfg.enable {
    services.zabbixAgent = {
      enable = true;
      package = pkgs.zabbix70.agent2;
      openFirewall = true;
      server = cfg.server;
      settings = {
        ServerActive = cfg.serverActive;
      };
    };
  };
}
