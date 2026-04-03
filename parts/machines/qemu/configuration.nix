# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	# this is basically the flake-parts boilerplate
	# the last part is the name you can reference in imports
	flake.nixosModules.qemuConfiguration = { pkgs, lib, hostname, username, ... }: {
		# the inside of these brackets is standard nixos configuration
		imports = [
			self.nixosModules.qemuHardware
			self.nixosModules.qemuSystem
			self.nixosModules.users
			self.nixosModules.mango
		];

		nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix commands and flakes
			nixpkgs.config.allowUnfree = true;

		environment.systemPackages = (with pkgs; [
			gh # todo move this to something like common/packages.nix, I also tried setting this using home-manager but the git-credential-helper had problem finding the proper binary
			
			firefox
			neovim
			discord
			sublime3 # just before i migrate my neovim config to home-manager
		]);

		# move to services module later
		services.avahi = { # enables .local address resolution
			enable = true;
			nssmdns4 = true;
			openFirewall = true;
			ipv4 = true;
			ipv6 = true;
		};

		desktops.mango.monitors = ''
			monitorrule=name:DP-2,width:2560,height:1440,refresh:144,x:2560,y:2639,scale:1
			monitorrule=name:HDMI-A-1,width:1920,height:1080,refresh:60,x:2560,y:1559,scale:1
			monitorrule=name:HDMI-A-2,width:2560,height:1440,refresh:60,x:1120,y:1519,scale:1,rr:1
		'';

		## SOUND
		services.pulseaudio.enable = false;

		## TOUCHPAD
		services.libinput.enable = true;

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

		# USB DRIVES
		services.udisks2.enable = true; # enable backend, then in home manager configure udiskie (frontend)

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
