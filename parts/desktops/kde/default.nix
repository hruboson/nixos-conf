{ self, inputs, ... }: {
	flake.nixosModules.kde = { config, lib, pkgs, username, ... }: {
		config = {
			services.desktopManager.plasma6.enable = true;

			services.displayManager.sddm = {
				enable = true;
				wayland.enable = true;
			};

			services.displayManager.defaultSession = lib.mkDefault "plasma";
			programs.xwayland.enable = true;

			environment.systemPackages = with pkgs; [
				kdePackages.milou
			];

			# only exludes!!! add packages you want in the block above
			environment.plasma6.excludePackages = with pkgs; [
				kdePackages.elisa # Music player
				kdePackages.kdepim-runtime # Akonadi agents
				kdePackages.kmahjongg
				kdePackages.kmines
				kdePackages.konversation # IRC client
				kdePackages.kpat # Solitaire
				kdePackages.ksudoku
				kdePackages.ktorrent
			];

			services.dbus.enable = true;
			security.polkit.enable = true;
			hardware.graphics.enable = true;

			home-manager.users.${username} = {
				# Dark mode carries over from the darkmode module,
				# but KDE manages its own theme — nothing extra needed here.
				# Add any KDE-specific home-manager config below if wanted.
			};
		};
	};
}
