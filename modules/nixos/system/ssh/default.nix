{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.ssh;
in {
  options.ikl.system.ssh = with types; {
    enable = mkBoolOpt false "Whether or not to enable SSH access.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [ "italik" ];
        X11Forwarding = false;
        PermitRootLogin = "yes";
      };
    };
  };
}
