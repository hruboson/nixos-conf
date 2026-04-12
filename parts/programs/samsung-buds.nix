{ self, inputs, ... }: {
	flake.nixosModules.samsungBuds = { pkgs, lib, username, ... }: {
		imports = [ self.nixosModules.servicesBluetooth ];

		environment.systemPackages = with pkgs; [
			galaxy-buds-client # GUI
			earbuds # CLI
		];
	};
}
