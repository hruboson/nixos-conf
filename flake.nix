{
	description = "Main NixOS configuration";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
		nur = {
			url = "github:nix-community/NUR";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		plasma-manager = {
			url = "github:nix-community/plasma-manager";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home-manager";
		};
		hyprland.url = "github:hyprwm/Hyprland";
		hyprland-plugins = {
			url = "github:hyprwm/hyprland-plugins";
			inputs.hyprland.follows = "hyprland";
		};
		Hyprspace = {
			url = "github:KZDKM/Hyprspace";
			inputs.hyprland.follows = "hyprland";
		};
  		snappy-switcher.url = "github:OpalAayan/snappy-switcher";
		mangowc = {
			url = "github:DreamMaoMao/mango";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nvim-conf = {
			url = "github:hruboson/nvim-conf";
			flake = false;
		};
		secrets = {
			url = "git+file:///home/hruon/nixos-conf/secrets"; # must be an absolute path
		};
		nix-minecraft = {
			url = "github:Infinidoge/nix-minecraft";
		};
	};

	outputs = { self, nixpkgs, nur, home-manager, plasma-manager, mangowc, nvim-conf, nix-minecraft, secrets, ... }@inputs:
		let
			username = "hruon";
			machines = {
				workstation = {
					hostname = "worknix";
					system = "x86_64-linux";
					homeFile = ./home/workstation.nix;
				};
				notebook = {
					hostname = "minix";
					system = "x86_64-linux";
					homeFile = ./home/workstation.nix;
				};
				server = {
					hostname = "servernix";
					system = "x86_64-linux";
					homeFile = ./home/server.nix;
				};
				raspberrypi =  {
					hostname = "nixosrpi3";
					system = "aarch64-linux";
					homeFile = ./home/raspberrypi.nix;
				};
			};

			# helper function creating machine configurations
			makeMachine = name: cfg: nixpkgs.lib.nixosSystem {
				system = cfg.system;
				specialArgs = { 
					inherit username secrets inputs; 
					hostname = cfg.hostname;
				};
				modules = [
					./common/common.nix
					./common/packages.nix
					./common/users.nix

					nur.modules.nixos.default

					# machine-related config
					./machines/${name}/configuration.nix
					
					# home-manager related config
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.sharedModules = [ # common for all machines
							./common/home.nix 
							plasma-manager.homeModules.plasma-manager 
						];
						home-manager.users.${username} = import cfg.homeFile;
						home-manager.extraSpecialArgs = {
							inherit nvim-conf inputs;
						};
					}
				];
			};
		in {
			nixosConfigurations = nixpkgs.lib.mapAttrs makeMachine machines;
		};
}
