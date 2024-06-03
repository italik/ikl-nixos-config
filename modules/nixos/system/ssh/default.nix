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
      hostKeys = [
        {
          path = "/data/secrets/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/data/secrets/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [ "italik" ];
        X11Forwarding = false;
        PermitRootLogin = lib.mkForce "yes";
      };
    };
  };
}
