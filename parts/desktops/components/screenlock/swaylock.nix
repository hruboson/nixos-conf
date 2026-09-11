{ self, inputs, ... }: {
  flake.nixosModules.screenlockSwaylockEffects =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      config = {
        security.pam.services.swaylock = { };
        security.polkit.enable = true;

        home-manager.users.${username} = {
          programs.swaylock = {
            enable = true;
            package = pkgs.swaylock-effects;

            settings = {
              daemonize = true;
              ignore-empty-password = true;
              show-failed-attempts = true;
              submit-on-touch = true;

              screenshots = true; # capture the current screen
              effect-blur = "8x3";
              effect-vignette = "0.35:0.5";
              effect-greyscale = true;
			  fade-in = 0.1;
              #grace = 3;

              clock = true;
              timestr = "%H:%M";
              datestr = "%A, %d %B";
              font = "JetBrainsMono Nerd Font";
              font-size = 70;

              # password ring
              indicator = true;
              indicator-radius = 150;
              indicator-thickness = 5;
              #indicator-idle-visible = true;

              #TODO take this color from stylix when stylix is implemented
              key-hl-color = "f3be7cff"; # for now this is the vague-yellow

              inside-color = "1e1e1e99";
              inside-clear-color = "1e1e1e99";
              inside-caps-lock-color = "1e1e1e99";
              inside-ver-color = "1e1e1e99";
              inside-wrong-color = "40202099";

              ring-color = "78787866";
              ring-clear-color = "dcdcdcff";
              ring-caps-lock-color = "dcdcdcff";
              ring-ver-color = "78787866";
              ring-wrong-color = "aa4444ff";

              line-color = "00000000";
              line-clear-color = "00000000";
              line-caps-lock-color = "00000000";
              line-ver-color = "00000000";
              line-wrong-color = "00000000";

              text-color = "dcdcdcff";
              text-clear-color = "dcdcdcff";
              text-caps-lock-color = "dcdcdcff";
              text-ver-color = "dcdcdcff";
              text-wrong-color = "dcdcdcff";

              separator-color = "00000000";
            };
          };

          services.hypridle = {
            enable = true;
            settings = {
              general = {
                before_sleep_cmd = "loginctl lock-session";
                after_sleep_cmd = "";
                ignore_dbus_inhibit = false;
                lock_cmd = "pidof swaylock || ${pkgs.swaylock-effects}/bin/swaylock";
              };
              listener = [
                {
                  timeout = 600;
                  on-timeout = "pidof swaylock || ${pkgs.swaylock-effects}/bin/swaylock";
                }
                {
                  timeout = 900;
                  on-timeout = "systemctl suspend";
                }
              ];
            };
          };

          wayland.windowManager.mango.autostart_sh = ''
            hypridle &
          '';

          wayland.windowManager.mango.settings.switchbind = [
            "fold,spawn_shell,systemctl suspend"
          ];
        };
      };
    };
}
