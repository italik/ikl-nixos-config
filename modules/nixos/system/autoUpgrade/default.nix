{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.system.users;
in {
  options.ikl.system.autoUpgrade = with types; {
    enable = mkBoolOpt false "Whether or not to enable automatic upgrades.";
  };

  config = mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      flake = "github:italik/ikl-nixos-config";
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
        "-L" # Print build logs
      ];
      dates = "04:00";
      randomizedDelaySec = "45min";
    };
    nix.gc = {
      automatic = true;
      dates = "daily";
      randomizedDelaySec = "1h";
      options = "--delete-older-than 14d";
    };
    nix.optimise = {
      automatic = true;
    };
  };
}
