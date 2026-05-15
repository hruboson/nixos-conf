{ self, inputs, ... }: {
	flake.nixosModules.brightnessWidget = { config, lib, pkgs, username, ... }: let
        brightnessController = pkgs.writeShellScriptBin "brightness-widget-controller" (
			# pkgs.writeShellScriptBin creates a derivation that puts the script
			# in /run/current-system/sw/bin/ under the given name
            builtins.readFile ./brightness-widget-controller.sh
        );
        brightnessWidget = pkgs.stdenv.mkDerivation {
            name = "brightness-qs-widget";
            src = ./.; # "source" files, can be used in installPhase
            installPhase = ''
                mkdir -p $out
                cp ${./widget.qml} $out/shell.qml
            '';
        };
        brightnessLauncher = pkgs.writeShellScriptBin "brightness-widget-toggle" ''
            if qs --config ${brightnessWidget} ipc call brightness-widget toggle 2>/dev/null; then
                exit 0 # end script
            fi
            qs --config ${brightnessWidget} & # not running - start
        '';

    in {
        options.desktops.components.brightnessWidget = {
            enable = lib.mkEnableOption "Brightness quickshell widget";

            showInWaybar = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Add a brightness button to waybar";
            };
        };
		config = lib.mkIf config.desktops.components.brightnessWidget.enable {
			environment.systemPackages = with pkgs; [
				qt6.qtimageformats # amog
				qt6.qt5compat # shader fx
				qt6.qtmultimedia # flicko shell
				qt6.qtdeclarative # qtdecl types in path
				quickshell # qs

				wl-gammarelay-rs
				brightnessctl
				brightnessController
				brightnessLauncher
			];

			
			systemd.user.services.wl-gammarelay-rs = {
				description = "Wayland gamma and brightness control service";
				after = [ "graphical-session.target" ];
				partOf = [ "graphical-session.target" ];
				wantedBy = [ "graphical-session.target" ];

				serviceConfig = {
					ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs";
					Restart = "on-failure";
					RestartSec = 5;
				};
			};

			desktops.waybar.config = lib.mkIf config.desktops.components.brightnessWidget.showInWaybar {
                "custom/brightness" = {
                    format = "󰃟";
                    tooltip = true;
                    tooltip-format = "Brightness";
                    on-click = "brightness-widget-toggle";
                };
            };
		};
	};
}
