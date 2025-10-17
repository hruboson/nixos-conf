# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
	imports =
		[ # Include the results of the hardware scan.
		./hardware-configuration.nix
			(import "${home-manager}/nixos")
		];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# HARDWARE

	## SOUND
	services.pulseaudio.enable = true;

	## TOUCHPAD
	services.libinput.enable = true;

	# NETWORK
	networking.hostName = "nixos-vm"; # Define your hostname.
	# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	networking.firewall.enable = true;

	# Enable the OpenSSH daemon and ssh-agent with keys
	services.openssh.enable = true;
	programs.ssh.startAgent = true;

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# FONTS
	fonts.packages = with pkgs; [
		pkgs.nerd-fonts.fira-code
	];

	# LOCALES
	
	# i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		keyMap = "cz-qwertz";
	};
	time.timeZone = "Europe/Prague";

	# USERS
	users.users.hruboson = { # Define a user account. Don't forget to set a password with ‘passwd’.
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
			packages = with pkgs; [];
	};

	home-manager.backupFileExtension = ".bak";
	home-manager.users.hruboson = { pkgs, ... }: let
		nvimConf = pkgs.fetchFromGitHub {
			owner = "hruboson";
			repo = "nvim-conf";
			rev = "main";
			sha256 = "039cpic7brgm69h2dmnrf92vjxasqp6mns8z2vic8sqczhk2r23v";
		};
	in {
		home.stateVersion = "25.05";
		programs.neovim = {
			enable = true;
			package = pkgs.neovim-unwrapped;

			extraConfig = ''
				set clipboard+=unnamedplus
			'';
		};

		home.file.".config/nvim".source = nvimConf;
		home.packages = [ pkgs.ripgrep pkgs.fzf pkgs.xclip ];
	};

	# programs.firefox.enable = true;

	# PROGRAMS

	environment.systemPackages = with pkgs; [ # List packages installed in system profile.
		# You can use https://search.nixos.org/ to find more packages (and options).
		wget
		pkgs.lazygit
		pkgs.nix-ld
		pkgs.nix-prefetch-git
	];

	programs.git = {
		enable = true;
		config = {
			user.name = "Ondřej Hruboš";
			user.email = "hruboson@gmail.com";
			init.defaultBranch = "main";
			pull.rebase = true;
		};
	};

	# MISC
	programs.nix-ld.enable = true;

	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	system.copySystemConfiguration = true;

	# VERSION
	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "25.05"; # Did you read the comment?
}

