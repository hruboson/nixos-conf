{ self, inputs, ... }: {
  flake.nixosModules.darkmode =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {

      home-manager.users.${username} = {
        imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

        home.sessionVariables = {
          QT_QPA_PLATFORMTHEME = "kde";
        };

        # enable dark mode for QT and GTK apps
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Adwaita-dark";
            color-scheme = "prefer-dark";
          };
        };

        gtk = {
          enable = true;
          gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

          theme = {
            name = "Adwaita-dark";
            package = pkgs.gnome-themes-extra;
          };

          # My favourite icon theme and also fixes some missing icons
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
        };

        programs.plasma = {
          enable = true;

          workspace = {
            colorScheme = "BreezeDark";
          };
        };
      };
    };
}
