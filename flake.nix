{
    inputs = {
		# NIXOS
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

		# CONFIG
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree"; # recursively imports the parts directory
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
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
    };
    outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {
		imports = [
		    inputs.home-manager.flakeModules.home-manager
			(inputs.import-tree ./parts)
		];
	};
}
