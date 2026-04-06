{ self, inputs, ... }: {
	flake.nixosModules.darkmode = { config, lib, pkgs, username, ... }: {

		home-manager.users.${username} = {
			# enable dark mode for QT and GTK apps
			dconf.settings = {
				"org/gnome/desktop/interface" = {
					gtk-theme = "Adwaita-dark";
					color-scheme = "prefer-dark";
				};
			};
			qt = {
				enable = true;
				platformTheme.name = "gtk";
				style.name = "adwaita-dark";
				style.package = pkgs.adwaita-qt;
			};
			gtk = {
				enable = true;
				gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
				gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

				theme = {
					name = "Adwaita-dark";
					package = pkgs.gnome-themes-extra;
				};

				# My favourite icon theme and also fixes some missing icons
				iconTheme = {
					name = "Papirus-Dark";
					package = pkgs.papirus-icon-theme;
				};
			};
		};
	};
}
