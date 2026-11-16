{ self, modules, ... }: {
  flake.nixosModules.waitingCatWidget =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      cfg = config.desktops.components.waitingCatWidget;
    in
    {
      options.desktops.components.waitingCatWidget = {
        enable = lib.mkEnableOption "Waiting cat GIF overlay (Quickshell)";

        output = lib.mkOption {
          type = lib.types.str;
          example = "HDMI-A-1";
          description = "Monitor the overlay is shown on.";
        };

        source = lib.mkOption {
          type = lib.types.either lib.types.path lib.types.str;
          description = "GIF to display. A Nix path is copied to the store; a string is used as an absolute runtime path.";
        };

        size = lib.mkOption {
          type = lib.types.int;
          default = 64;
        };
        right = lib.mkOption {
          type = lib.types.int;
          default = 8;
        };

        gap = lib.mkOption {
          type = lib.types.int;
          default = 3;
          description = "Extra space between the overlay and the bar.";
        };

        bottom = lib.mkOption {
          type = lib.types.int;
          default = config.desktops.waybar.config.height + cfg.gap;
          defaultText = "waybar height + gap";
          description = "Bottom margin in px.";
        };
      };

      config = lib.mkIf cfg.enable {
        home-manager.users.${username} = {
          home.packages = [ pkgs.quickshell ];

          systemd.user.services.waiting-cat-widget = {
            Unit = {
              Description = "Waiting cat GIF overlay (Quickshell)";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${lib.getExe pkgs.quickshell} -p ${./shell.qml}";
              Restart = "on-failure";
              RestartSec = 2;
              Environment = [
                "CAT_GIF_OVERLAY_OUTPUT=${cfg.output}"
                "CAT_GIF_OVERLAY_SOURCE=${cfg.source}"
                "CAT_GIF_OVERLAY_SIZE=${toString cfg.size}"
                "CAT_GIF_OVERLAY_BOTTOM=${toString cfg.bottom}"
                "CAT_GIF_OVERLAY_RIGHT=${toString cfg.right}"
              ];
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
}
