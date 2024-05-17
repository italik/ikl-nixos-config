{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.impermanence;
in {
  options.ikl.system.impermanence = with types; {
    enable = mkBoolOpt false "Whether or not to enable impermanence.";
  };

  config = mkIf cfg.enable {
    environment.etc."machine-id".source = "/data/secrets/machine-id";
  };
}
