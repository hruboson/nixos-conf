{
    inputs = {
		# NIXOS
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		# CONFIG
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree"; # recursively imports the parts directory
		home-manager = {
			url = "github:nix-community/home-manager";
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
    outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./parts);
}
