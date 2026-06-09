{ self, inputs, ... }: {
	flake.nixosModules.barWidget = { config, lib, pkgs, username, ... }: {
		options.desktops.components.bar = {
            enable = lib.mkEnableOption "Enable the quickshell bar, enables every other component that works with it.";
        };

		config = lib.mkIf config.desktops.components.bar.enable {
			environment.systemPackages = with pkgs; [
				qt6.qtimageformats # amog
				qt6.qt5compat # shader fx
				qt6.qtmultimedia # flicko shell
				qt6.qtdeclarative # qtdecl types in path
				quickshell # qs
			];

			home-manager.users.${username} = {
				wayland.windowManager.mango.autostart_sh = ''
					while true; do
						qs -p ${./bar.qml } >> ~/.cache/qsbar_log.log 2>&1
						sleep 2
					done &
				'';
			};
		};
	};
}
