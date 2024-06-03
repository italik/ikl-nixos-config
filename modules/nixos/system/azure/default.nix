{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.azure;
in {
  options.ikl.system.azure = with types; {
    enable = mkBoolOpt false "Whether or not to enable Azure extensions.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.waagent
    ];
  };
}
