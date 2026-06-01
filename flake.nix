{
    inputs = {
		# NIXOS
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

		# CONFIG
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree"; # recursively imports the parts directory
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixvim = {
			url = "github:nix-community/nixvim/nixos-26.05";
		};

		# DESKTOPS
		mango = {
			url = "github:mangowm/mango";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		silentSDDM = {
			url = "github:uiriansan/SilentSDDM";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		snappy-switcher.url = "github:OpalAayan/snappy-switcher";
		awww.url = "git+https://codeberg.org/LGFae/awww";

		# ADDITIONAL DOTFILES

		# currently not used, nvim managed through nixvim
		#nvim-conf = {
		#	url = "github:hruboson/nvim-conf";
		#	flake = false;
		#};

		# SERVER

		# secret management through local-only repo (until I learn sops-nix)
		secrets = {
			url = "git+file:///home/hruon/nixos-conf/secrets"; # must be an absolute path
		};
		nix-minecraft = {
			url = "github:Infinidoge/nix-minecraft";
		};

		# PERSONAL PROJECTS
		tropikey = {
			url = "github:hruboson/tropikey";
			inputs.nixpkgs.follows = "nixpkgs";
		};
    };
    outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {
		imports = [
		    inputs.home-manager.flakeModules.home-manager
			(inputs.import-tree [ ./parts ./machines ])
		];
	};
}
