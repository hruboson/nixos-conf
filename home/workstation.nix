{ pkgs, lib, inputs, ... }:

let
	wallpapers = pkgs.fetchFromGitHub {
		owner = "hruboson";
		repo = "wallpapers";
		rev = "076ef62d06dfe05a64d97f695d89c9d133ab20f5";
		sha256 = "sha256-uT6SFrHbARkz7eRLg2KBJUNgMM+jrVltv+qBmBMA0uM=";
	};

	hypr-overview = pkgs.fetchFromGitHub {
		owner = "Shanu-Kumawat";
		repo = "quickshell-overview";
		rev = "main";
		sha256 = "sha256-tGYvmzYOnaEyC/65NzeMKAdWK8yAQnAO0g2ykIHM3U8=";
	};
in
{
	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';

	xdg.configFile."quickshell/overview".source = hypr-overview;

	home.packages = lib.mkAfter (with pkgs; [
		home-manager

		firefox # todo replace with waterfox later
		kdePackages.filelight
		papirus-icon-theme
	]);

	# source wallpapers from github repo to .config/wallpapers
	home.file.".config/wallpapers" = {
		source = wallpapers;
		force = true;
	};

	# enable dark mode for QT and GTK apps
	dconf.settings = {
		"org/gnome/desktop/interface" = {
			gtk-theme = "Breeze-Dark";
			color-scheme = "prefer-dark";
		};
	};
	qt = {
		enable = true;
		platformTheme.name = "gtk";
		style.name = "breeze";
		style.package = pkgs.kdePackages.breeze.qt5;
	};
	gtk = {
		enable = true;
		gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
		gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

		theme = {
			name = "Breeze-Dark";
			package = pkgs.kdePackages.breeze-gtk;
		};

		# My favourite icon theme and also fixes some missing icons
		iconTheme = {
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};
	};
	home.activation.initKdeGlobals =
		lib.hm.dag.entryAfter ["writeBoundary"] ''
		if [ ! -f "$HOME/.config/kdeglobals" ]; then
			install -Dm644 \
			${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors \
			"$HOME/.config/kdeglobals"
		fi
	'';

	# PLASMA MANAGER
	programs.plasma = {
		enable = true;
		workspace = {
			theme = "breeze-dark";
			iconTheme = "Papirus";
			soundTheme = "freedesktop";

			splashScreen.theme = "a2n.kuro";
			windowDecorations = {
				library = "org.kde.kdecoraion2";
				theme = "__aurorae__svg__WillowDarkShader";
			};
		};
	};	

	services.udiskie.enable = true;
	services.udiskie.settings = {
		automount = true; # automatically mount drives
		automount_options = ["rw" "uid=1000" "gid=100"]; # UID/GID matches user
		notify = true; # desktop notifications
		file_manager = pkgs.doublecmd; # integrate with file manager
	};

	# Default apps associations
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

			# Archives → PeaZip
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

	# Custom desktop entries
	xdg.desktopEntries.scrcpy = {
		name = "scrcpy";
		genericName = "Android Remote Control";
		comment = "Display and control your Android device";
		exec = "scrcpy --render-driver=opengl";
		icon = "scrcpy";
		terminal = false;
		categories = [ "Utility" "RemoteAccess" ];
	};

	xdg.configFile."sway/config".text = ''
		include ~/.config/sway/*.conf
	'';

	# Custom cursor
	home.pointerCursor = let 
		getFrom = url: hash: name: {
			gtk.enable = true;
			x11.enable = true;
			name = name;
			size = 48;
			package = 
				pkgs.runCommand "moveUp" {} ''
				mkdir -p $out/share/icons
				ln -s ${pkgs.fetchzip {
					url = url;
					hash = hash;
				}} $out/share/icons/${name}
			'';
		};
	in
		getFrom 
		"https://github.com/polirritmico/Breeze-Dark-Cursor/releases/download/v1.0/Breeze_Dark_v1.0.tar.gz"
		"sha256-FgqS3rHJ4o5x4ONSaDZlQu1sFhefhWPk8vaBvURKZzY=" # get this hash by running nix store prefetch-file https://github/cursortheme/theme.tar.gz ... if this hash is wrong you wont be able to rebuild the system
		"Breeze-Dark";
}
