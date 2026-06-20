{ self, inputs, ... }: {
	flake.nixosModules.fractusConfiguration = { pkgs, lib, hostname, username, ... }: {
		imports = [
			self.nixosModules.fractusHardware
			self.nixosModules.fractusSystem
			self.nixosModules.users

			self.nixosModules.mango
			self.nixosModules.kitty
			self.nixosModules.appPackDev
			self.nixosModules.appPackNetworking
			self.nixosModules.appPackSysutils
			self.nixosModules.appPackDesktop
			self.nixosModules.appPackEducation
			self.nixosModules.appPack3D
			self.nixosModules.appPackRazer

			self.nixosModules.servicesPackHomeserver
			self.nixosModules.servicesBluetooth
			self.nixosModules.servicesDisks
		];

		nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix commands and flakes
		nixpkgs.config.allowUnfree = true;

		desktops.mango.monitors = ''
			monitorrule=name:eDP-1,width:1920,height:1080,refresh:60,x:0,y:0,scale:1
		'';
		desktops.lockscreen.background = pkgs.fetchurl {
			name = "moody_blues.webp";
			url = "https://raw.githubusercontent.com/hruboson/wallpapers/refs/heads/main/jjba/jjba_moody_blues.webp";
			hash = "sha256-lMTHuOt4fFEMcRr7kaBYxpaOfhyOmXrDpUbaV9vMDDc=";
		};

		desktops.lockscreen.profilePicture = pkgs.fetchurl {
			name = "hruon_logo.jpg";
			url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/logos/logos_inversion.png";
			hash = "sha256-7oa2vQaWmsQ+evWES1XNVBfI///McOv+J/9urFN1kEM=";
		};

		## SOUND
		services.pulseaudio.enable = false;

		## TOUCHPAD
		services.libinput.enable = true;

		# BUTTONS
		services.logind.settings.Login = {
			HandlePowerKey = "suspend";
			HandlePowerKeyLongPress = "poweroff";
			HandleLidSwitch = "suspend";
			HandleLidSwitchExternalPower= "suspend";
		};

		# LOCALES
		console = {
			font = "Lat2-Terminus16";
			keyMap = "cz-qwertz";
		};
		time.timeZone = "Europe/Prague";

		i18n.defaultLocale = "en_US.UTF-8";
		i18n.extraLocaleSettings = {
			LC_ADDRESS = "cs_CZ.UTF-8";
			LC_IDENTIFICATION = "cs_CZ.UTF-8";
			LC_MEASUREMENT = "cs_CZ.UTF-8";
			LC_MONETARY = "cs_CZ.UTF-8";
			LC_NAME = "cs_CZ.UTF-8";
			LC_NUMERIC = "cs_CZ.UTF-8";
			LC_PAPER = "cs_CZ.UTF-8";
			LC_TELEPHONE = "cs_CZ.UTF-8";
			LC_TIME = "cs_CZ.UTF-8";
		};


		# NETWORK
		#networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
		networking.firewall.enable = true;

		# Enable the OpenSSH daemon and ssh-agent with keys
		services.openssh.enable = true;
		programs.ssh.startAgent = true;

		# MISC
		programs.nix-ld.enable = true;

		# if build is too slow change this line to nix.optimise.automatic = true;
		nix.settings.auto-optimise-store = true; # optimise /nix/store space

		# garbage collector
		nix.gc = {
			automatic = true;
			options = "--delete-older-than 14d";
		};
	};
}
