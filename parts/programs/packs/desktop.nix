{ self, inputs, ... }: {
	flake.nixosModules.appPackDesktop = { config, lib, pkgs, username, ... }: {
		nixpkgs.config.allowUnfree = true;
		environment.systemPackages = with pkgs; [
			# files
			kdePackages.filelight
			kdePackages.dolphin kdePackages.ffmpegthumbs kdePackages.qtimageformats
			peazip

			# img
			oculante
			gthumb
			
			# emulator
			bottles

			# communications
			discord
			element-desktop
			
			# other
			firefox
			libreoffice-fresh
		];

		# should fix kde unpopulated xdg mime apps menu
		environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

		home-manager.users.${username} = {
			# File types -> app associations
			# mimetype.io/all-types
			xdg.mimeApps = {
				enable = true;
				defaultApplications = {
					# Images
					"image/jpeg" = "oculante.desktop";
					"image/png" = "oculante.desktop";
					"image/webp" = "oculante.desktop";
					"image/gif" = "oculante.desktop";
					"image/bmp" = "oculante.desktop";
					"image/tiff" = "oculante.desktop";
					"image/svg+xml" = "oculante.desktop";

					# Directories
					"inode/directory" = "org.kde.dolphin.desktop";

					# Documents
					"application/pdf" = "firefox.desktop";
					"text/markdown" = "firefox.desktop";

					# Archives -> PeaZip
					"application/zip" = "peazip.desktop";
					"application/x-zip-compressed" = "peazip.desktop";
					"application/x-rar" = "peazip.desktop";
					"application/vnd.rar" = "peazip.desktop";
					"application/x-7z-compressed" = "peazip.desktop";
					"application/x-tar" = "peazip.desktop";
					"application/gzip" = "peazip.desktop";
					"application/x-gzip" = "peazip.desktop";
					"application/x-bzip2" = "peazip.desktop";
					"application/x-xz" = "peazip.desktop";
					"application/zstd" = "peazip.desktop";
				};
			};
		};
	};
}
