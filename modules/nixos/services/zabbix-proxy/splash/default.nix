{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-proxy.splash;
in {
  options.ikl.services.zabbix-proxy.splash = with types; {
    enable = mkBoolOpt false "Whether or not to enable the splash screen for Zabbix Proxy appliances.";
  };

  config = mkIf cfg.enable {
    systemd.services."tty-splash" = mkIf cfg.enable {
      description = "Italik TTY Splash Screen";
      before = [ "getty@tty1.service" ];
      after = [ "multi-user.target" ];
      conflicts = [ "getty@tty1.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        StandardInput = "tty";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
        Restart = "always";
        RestartSec = 2;
      };
      script = ''
        #!/bin/bash

        clear

        # Define colors
        RED='\033[1;31m'
        GREEN='\033[1;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[1;34m'
        NC='\033[0m' # No Color

        # Display the splash screen
        echo -e "${GREEN}"
        echo "====================================="
        echo "    Italik Zabbix Proxy Appliance    "
        echo "====================================="
        echo -e "${NC}"
        echo -e "${YELLOW}Press F12 to log in...${NC}"

        # Wait for F12 to be pressed
        while true; do
          read -rsn1 key
          if [[ "$key" == $'\x7f' ]]; then  # F12 Key (Scan Code)
            clear
            systemctl restart getty@tty1
            exit
          fi
        done
      '';
    };
  };
}
