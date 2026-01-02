{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.syslog;
  dest = "syslog.italikintra.net";
in {
  options.ikl.system.syslog = with types; {
    enable = mkBoolOpt false "Whether or not to enable syslog forwarding.";
    sftpgo = mkBoolOpt false "Whether or not to enable forwarding of sftpgo logs.";
  };

  config = mkIf cfg.enable {
    services.rsyslogd = {
      enable = true;
      defaultConfig = ''
        global(DefaultNetstreamDriverCAFile="/etc/ssl/certs/ca-bundle.crt")

        ${lib.optionalString cfg.sftpgo ''
          # SFTPGo logs to alternative port
          if ($syslogtag == "sftpgo") then {
            action(
              type="omfwd"
              target="${dest}"
              port="4514"
              protocol="tcp"
              StreamDriver="gtls"
              StreamDriverAuthMode="anon"
              StreamDriverMode="1"
              action.resumeRetryCount="100"
              queue.type="linkedList"
              queue.size="10000"
            )
            stop
          }
        ''}

        *.* action(
            type="omfwd"
            target="${dest}"
            port="2514"
            protocol="tcp"
            StreamDriver="gtls"
            StreamDriverAuthMode="anon"
            StreamDriverMode="1"
            action.resumeRetryCount="100"
            queue.type="linkedList"
            queue.size="10000"
        )
      '';
      extraConfig = mkIf cfg.sftpgo ''
        module(load="imfile")
        input(type="imfile"
              File="/var/log/sftpgo/sftpgo.log"
              Tag="sftpgo"
              Severity="info"
              Facility="ftp")
      '';
    };

    systemd.services.sftpgo.environment.SFTPGO_LOG_FILE_PATH = mkIf cfg.sftpgo "/var/log/sftpgo/sftpgo.log";
    systemd.services.sftpgo.serviceConfig.LogsDirectory = "sftpgo";

  };
}
