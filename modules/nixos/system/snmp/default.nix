{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.snmp;
in {
  options.ikl.system.snmp = with types; {
    enable = mkBoolOpt false "Whether or not to enable SNMP responses.";
  };

  config = mkIf cfg.enable {
    services.snmpd = {
      enable = true;

      openFirewall = true;
      configFile = config.sops.templates."snmpd_config.conf".path;
    };
  };
}
