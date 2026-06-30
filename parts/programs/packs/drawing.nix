{ self, inputs, ... }:
{
  flake.nixosModules.appPackDrawing =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        inkscape-with-extensions
        gimp-with-plugins
		scribus
      ];

      # PhotoGIMP: GIMP patch for Photoshop-like layout
      # Declaratively fetches and extracts the official PhotoGIMP zip
      # Copies files instead of symlinking so GIMP can write to them
      # Reference: https://github.com/Diolinux/PhotoGIMP
      home-manager.users.${username} = { config, lib, pkgs, ... }:
        let
          photogimp-extracted = pkgs.fetchzip {
            url = "https://github.com/Diolinux/PhotoGIMP/releases/download/3.0/PhotoGIMP-linux.zip";
            sha256 = "sha256-g7JNSr6LczV0uHvy5UjRwDwVkWTGMFRd0bW9RaBoDjM==";
            stripRoot = true;
          };
        in
        {
          home.activation.photogimp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            rm -rf ~/.config/GIMP/3.0
            mkdir -p ~/.config/GIMP
            cp -r ${photogimp-extracted}/.config/GIMP/3.0 ~/.config/GIMP/
            chmod -R u+w ~/.config/GIMP/3.0
          '';
        };
    };
}
