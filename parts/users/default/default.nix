{ ... }: {
  flake.nixosModules.userDefault =
    {
      pkgs,
      lib,
      username,
      ...
    }:
    {
      users.groups.media = { }; # group for external drives that need both services and user access

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
          "media"
        ];

        # Add your own public keys to log in over SSH:
        openssh.authorizedKeys.keys = [ ];
      };

      nix.settings.trusted-users = [
        "root"
        username
      ];

      home-manager.users.${username} = {
        home.username = username;
        # Set this to the NixOS release you first installed with and never change it.
        home.stateVersion = "26.05";

        programs.git.enable = true;
        # Uncomment and fill in to set your git identity:
        # programs.git.settings.user = {
        #   name = "Your Name";
        #   email = "you@example.com";
        # };
      };
    };
}
