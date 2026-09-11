{ self, inputs, ... }: {
  flake.nixosModules.appPackAndroid =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {

      nixpkgs.config.allowUnfree = true;
	  
	  services.gvfs.enable = true;

      environment.systemPackages = with pkgs; [
        android-file-transfer
        scrcpy
      ];

    };
}
