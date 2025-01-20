{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-agent;
in {
  options.ikl.services.zabbix-agent = with types; {
    enable = mkBoolOpt false "Whether or not to enable Zabbix Agent.";
    server = mkOpt str "zabbix.italikintra.net" "Zabbix Server or Proxy to connect to for Passive checks.";
    serverActive = mkOpt str cfg.server "Zabbix Server or Proxy to connect to for Active checks";
    psk.enable = mkBoolOpt false "Whether or not to enable Zabbix Agent communication encryption with PSK";
    psk.identity = mkOpt str "" "Zabbix PSK Identity";
    psk.file = mkOpt str "" "Zabbix PSK File location";
  };

  config = mkIf cfg.enable {
    services.zabbixAgent = {
      enable = true;
      package = pkgs.zabbix70.agent2;
      openFirewall = true;
      server = cfg.server;
      settings = {
        ServerActive = cfg.serverActive;
        TLSAccept = if cfg.psk.enable then "psk" else null;
        TLSConnect = if cfg.psk.enable then "psk" else null;
        TLSPSKIdentity = cfg.psk.identity;
        TLSPSKFile = cfg.psk.file;
      };
    };
  };
}
