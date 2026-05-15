{ self, inputs, ... }: {
	flake.nixosModules.cumulusConfiguration = { pkgs, lib, hostname, username, ... }: {
		imports = [
			self.nixosModules.cumulusHardware
			self.nixosModules.cumulusSystem
			self.nixosModules.users

			self.nixosModules.kitty
			self.nixosModules.appPackNetworking
			self.nixosModules.appPackDev
			self.nixosModules.servicesPackHomeserver

			self.nixosModules.selfhostedAudiobookshelf
			self.nixosModules.selfhostedDeluge
			self.nixosModules.selfhostedForgejo
			self.nixosModules.selfhostedGlance
			self.nixosModules.selfhostedJellyfin
			self.nixosModules.selfhostedKomga
			self.nixosModules.selfhostedLinkwarden
			self.nixosModules.selfhostedMatrix
			self.nixosModules.selfhostedMinecraftServer
			self.nixosModules.selfhostedPlikd
			self.nixosModules.selfhostedTailscale
			self.nixosModules.selfhostedTandoor
		];

		nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix commands and flakes
		nixpkgs.config.allowUnfree = true;

		environment.systemPackages = with pkgs; [
			ntfs3g
		];

		programs.wayvnc.enable = true;
		security.polkit.enable = true;

		services.avahi = {
			enable = true;
			nssmdns4 = true;
			publish.enable = true;
			publish.domain = true;
			publish.addresses = true;
		};

		#TODO find a way to put this into modules
		services.postgresql = {
			enable = true;

			initialScript = pkgs.writeText "postgres-init.sql" ''
			CREATE USER "matrix-synapse";
			CREATE USER "linkwarden";

			-- Matrix Synapse MUST use C collation
			CREATE DATABASE "matrix-synapse"
			WITH OWNER = "matrix-synapse"
			ENCODING = 'UTF8'
			LC_COLLATE = 'C'
			LC_CTYPE = 'C'
			TEMPLATE = template0;

			-- Linkwarden can use defaults
			CREATE DATABASE linkwarden
			WITH OWNER = linkwarden;
			'';


			# Allow local Unix socket connections and TCP from localhost
			authentication = lib.mkOverride 10 ''
				local   all             all                                     trust
				host    all             all             127.0.0.1/32            trust
				host    all             all             ::1/128                 trust
			'';
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
