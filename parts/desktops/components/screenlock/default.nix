{ self, inputs, ... }: {
  flake.nixosModules.screenlock =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      config = {
		security.pam.services.hyprlock = {};
        security.polkit.enable = true;
        home-manager.users.${username} = {
          programs.hyprlock = {
            enable = true;
            settings = {
              general = {
                hide_cursor = true;
                ignore_empty_input = true;
              };
              background = [
                {
                  path = "screenshot";
                  blur_passes = 3;
                  blur_size = 8;
                  noise = 0.02;
                  contrast = 1.1;
                  brightness = 0.8;
                  vibrancy = 0.2;
                }
              ];

              label = [
                {
                  # CLOCK
                  text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +"%H:%M"'';
                  color = "rgba(220, 220, 220, 1.0)";
                  font_size = 96;
                  font_family = "JetBrainsMono Nerd Font";
                  position = "0, 80";
                  halign = "center";
                  valign = "center";
                }

                {
                  # DATE
                  text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +"%A, %d %B"'';
                  color = "rgba(200, 200, 200, 0.8)";
                  font_size = 22;
                  font_family = "JetBrainsMono Nerd Font";
                  position = "0, 10";
                  halign = "center";
                  valign = "center";
                }
              ];

              input-field = [
                {
                  size = "280, 50";
                  outline_thickness = 2;
                  outer_color = "rgba(120,120,120,0.3)";
                  inner_color = "rgba(30,30,30,0.6)";
                  font_color = "rgba(220,220,220,1.0)";

                  fade_on_empty = false;
                  placeholder_text = "Password...";

                  dots_center = true;

                  position = "0, -80";
                  halign = "center";
                  valign = "center";
                }
              ];
            };
          };
          services.hypridle = {
            enable = true;
            settings = {
              general = {
                before_sleep_cmd = "loginctl lock-session";
                after_sleep_cmd = "";
                ignore_dbus_inhibit = false;
                lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
              };
              listener = [
                {
                  timeout = 600;
                  on-timeout = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
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
