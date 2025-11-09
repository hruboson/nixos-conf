{
	description = "Main NixOS configuration";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		plasma-manager = {
			url = "github:nix-community/plasma-manager";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home-manager";
		};
		secrets = {
			url = "git+file:///home/hruon/nixos-conf/secrets"; # must be an absolute path
		};
	};

	outputs = { self, nixpkgs, home-manager, plasma-manager, secrets, ... }@inputs:
		let
			username = "hruon";
			machines = {
				workstation = {
					hostname = "worknix";
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
					inherit username secrets; 
					hostname = cfg.hostname;
				};
				modules = [
					./common/common.nix
					./common/packages.nix
					./common/users.nix

					# machine-related config
					./machines/${name}/configuration.nix
					
					# home-manager related config
					home-manager.nixosModules.home-manager {
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.sharedModules = [ ./common/home.nix plasma-manager.homeModules.plasma-manager ]; # common for all machines
						home-manager.users.${username} = import cfg.homeFile;
					}
				];
			};
		in {
			nixosConfigurations = nixpkgs.lib.mapAttrs makeMachine machines;
		};
}
