{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.users;
in {
  options.ikl.system.users = with types; {
    enable = mkBoolOpt false "Whether or not to manage user accounts with this file.";
  };

  config = mkIf cfg.enable {
    users = {
      mutableUsers = false;
      users = {
        root.hashedPasswordFile = "/data/secrets/root";
        italik = {
          isNormalUser = true;
          hashedPasswordFile = "/data/secrets/italik";
          extraGroups = [
            "wheel"
            "nix"
          ];
        };
      };
    };
  };
}
