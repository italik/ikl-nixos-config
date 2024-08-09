{config, lib, pks, ...}:

{
  sops.templates."snmpd_config.conf" = {
    owner = "root";
    content = ''
rocommunity ${config.sops.placeholder.snmpd-string} ${config.sops.placeholder.snmpd-ip}
    '';
  };
}
