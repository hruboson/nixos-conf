{ self, inputs, ... }: {
	flake.nixosModules.humilisConfiguration = { pkgs, lib, hostname, username, ... }: {
		imports = [
			self.nixosModules.humilisHardware
			self.nixosModules.humilisSystem
			self.nixosModules.users

			self.nixosModules.vtm
			self.nixosModules.kitty
			self.nixosModules.appPackDev
			self.nixosModules.appPackNetworking
			self.nixosModules.appPackSysutils

			self.nixosModules.servicesPackHomeserver
			self.nixosModules.servicesBluetooth
			self.nixosModules.servicesDisks
		];

		nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix commands and flakes
		nixpkgs.config.allowUnfree = true;

		/*
		 * ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! 
		 * Change or comment this if you do not provide public ssh key as you will not be able to log in without it.
		 * ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! 
		 */
		services.getty.autologinUser = lib.mkForce null;

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
