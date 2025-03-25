{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.syslog;
in {
  options.ikl.system.syslog = with types; {
    enable = mkBoolOpt false "Whether or not to enable syslog forwarding.";
  };

  config = mkIf cfg.enable {
    services.rsyslogd = {
      enable = true;
      defaultConfig = ''
        global(DefaultNetstreamDriverCAFile="/etc/ssl/certs/ca-bundle.crt")
        *.* action(type="omfwd" target="syslog.italikintra.net" port="2514" protocol="tcp" StreamDriver="gtls" StreamDriverMode="1" action.resumeRetryCount="100" queue.type="linkedList" queue.size="10000")
      '';
    };
  };
}
