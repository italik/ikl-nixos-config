{config, lib, pks, ...}:

{
  ikl.system.snmp.enable = true;
  sops.templates."snmpd_config.conf" = {
    owner = "root";
    content = ''
rocommunity ${config.sops.placeholder.snmpd-string} ${config.sops.placeholder.snmpd-ip}
    '';
  };
}
