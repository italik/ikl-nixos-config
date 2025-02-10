{ options, config, lib, pkgs, ... }:
with lib;
with lib.ikl; let
  cfg = config.ikl.services.zabbix-proxy.splash;
in {
  options.ikl.services.zabbix-proxy.splash = with types; {
    enable = mkBoolOpt false "Whether or not to enable the splash screen for Zabbix Proxy appliances.";
  };

  config = mkIf cfg.enable {
    # Disable getty as it conflicts with our splash screen
    systemd.services."tty-splash" = mkIf cfg.enable {
      description = "Italik TTY Splash Screen";
      before = [ "getty@tty1.service" ];
      after = [ "multi-user.target" ];
      conflicts = [ "getty@tty1.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        bash
        busybox
      ];
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

        # Display the splash screen
        echo -e "\033[1;32m"
        echo "====================================="
        echo "    Italik Zabbix Proxy Appliance    "
        echo "====================================="
        echo -e "\033[0m"
        echo -e "\033[1;31mSupport Telephone: 01937 848380\033[0m"
        echo -e "\033[1;31mSupport Email: support@italik.co.uk\033[0m"
        echo -e "\033[0m"
        echo -e "\033[1;33mTesting connectivity to the Zabbix server"
        echo -e "\033[1;33mTesting connection to zabbix.italikintra.net on TCP port 443"
        nc -zw5 zabbix.italikintra.net 443 && {
          echo -e "\033[1;32mConnection test to zabbix.italikintra.net on TCP port 443 succeeded"
        } || {
          echo -e "\033[1;31mFailed to reach zabbix.italikintra.net on TCP port 443"
        }
        echo -e "\033[1;33mTesting connection to zabbix.italikintra.net on TCP port 10051"
        nc -zw5 zabbix.italikintra.net 10051 && {
          echo -e "\033[1;32mConnection test to zabbix.italikintra.net on TCP port 10051 succeeded"
        } || {
          echo -e "\033[1;31mFailed to reach zabbix.italikintra.net on TCP port 10051"
        }
        echo -e "\033[0m"
        echo -e "\033[1;33mConnectivity tests finished"
        echo -e "\033[0m"
        echo -e "\033[1;33mSystem boot completed"
        echo -e "\033[0m"
        echo -e "\033[1;33mPress ESC twice to log in...\033[0m"
        echo -e "\033[1;33mPress Ctrl+Alt+Delete to reboot...\033[0m"

        # Wait for ESC to be pressed
        while true; do
          read -n 1 key
          if [[ "$key" == $'\e' ]]; then  # Escape character
            read -n 1 key2
            if [[ "$key" == $'\e' ]]; then
              clear
              systemctl restart getty@tty1
              exit
            fi
          fi
        done
      '';
    };
  };
}
