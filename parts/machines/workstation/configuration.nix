# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	# this is basically the flake-parts boilerplate
	# the last part is the name you can reference in imports
	flake.nixosModules.workstationConfiguration = { pkgs, lib, hostname, username, ... }: {
		# the inside of these brackets is standard nixos configuration
		imports = [
			self.nixosModules.workstationHardware
			self.nixosModules.workstationSystem
			self.nixosModules.users
			self.nixosModules.mango
		];

		nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable nix commands
		nixpkgs.config.allowUnfree = true;

		environment.systemPackages = (with pkgs; [
			firefox
			neovim
			kitty
		]);

		desktops.mango.monitors = ''
		monitorrule=name:DP-2,width:2560,height:1440,refresh:144,x:2560,y:2639,scale:1
		monitorrule=name:HDMI-A-1,width:1920,height:1080,refresh:60,x:2560,y:1559,scale:1
		monitorrule=name:HDMI-A-2,width:2560,height:1440,refresh:60,x:1120,y:1519,scale:1,transform:3
		'';
	};
}
