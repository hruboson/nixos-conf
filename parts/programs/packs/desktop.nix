{ self, inputs, ... }: {
  flake.nixosModules.appPackDesktop =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        with pkgs;
        let
          application-menu = pkgs.runCommandLocal "xdg-application-menu" { } ''
            mkdir -p $out/etc/xdg/menus/
            ln -s ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu \
            $out/etc/xdg/menus/applications.menu
          '';
        in
        [
          # files
          kdePackages.filelight
          kdePackages.ark
          kdePackages.dolphin
          kdePackages.ffmpegthumbs
          kdePackages.qtimageformats
          application-menu
          android-file-transfer

          # img, video, audio
          oculante
          gthumb
          vlc
          spotify
          quodlibet

          # emulator
          bottles

          # communications
          #discord -> now managed through HM
          element-desktop # matrix client
		  fluffychat # matrix client

          # browser
          firefox
          floorp-bin

          # office
          libreoffice-fresh

          # other
          gnome-software

          # archive backends for ark
          unrar
          p7zip
          libarchive
          zip
          unzip
          gnutar
          gzip
          bzip2
          xz
          zstd
          lrzip
          lzop
        ];

      # enable flatpak (for imperative installs -- sure, go for it)
      services.flatpak.enable = true;
      systemd.services.flatpak-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        '';
      };
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      # should fix kde unpopulated xdg mime apps menu
      environment.etc."/xdg/menus/applications.menu".text =
        builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
      xdg.mime.enable = true;
      xdg.menus.enable = true;
      xdg.portal.enable = true;

      home-manager.users.${username} = {
        nixpkgs.config.allowUnfree = true;
        programs.discord.enable = true;

		# run apps without confirmation (Dolphin)
        xdg.configFile."kiorc".text = ''
          [Executable scripts]
          behaviourOnLaunch=execute
        '';

        # File types -> app associations
        # mimetype.io/all-types
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            # Images
            "image/jpeg" = "oculante.desktop";
            "image/png" = "oculante.desktop";
            "image/webp" = "oculante.desktop";
            "image/gif" = "oculante.desktop";
            "image/bmp" = "oculante.desktop";
            "image/tiff" = "oculante.desktop";
            "image/svg+xml" = "oculante.desktop";

            # Directories
            "inode/directory" = "org.kde.dolphin.desktop";

            # Links
            "text/html" = "firefox.desktop";
            "x-scheme-handler/http" = "firefox.desktop";
            "x-scheme-handler/https" = "firefox.desktop";
            "x-scheme-handler/about" = "firefox.desktop";
            "x-scheme-handler/unknown" = "firefox.desktop";

            # Documents
            "application/pdf" = "firefox.desktop";
            "text/markdown" = "firefox.desktop";

            # Archives -> PeaZip
            "application/zip" = "org.kde.ark.desktop";
            "application/x-zip-compressed" = "org.kde.ark.desktop";
            "application/x-rar" = "org.kde.ark.desktop";
            "application/vnd.rar" = "org.kde.ark.desktop";
            "application/x-7z-compressed" = "org.kde.ark.desktop";
            "application/x-tar" = "org.kde.ark.desktop";
            "application/gzip" = "org.kde.ark.desktop";
            "application/x-gzip" = "org.kde.ark.desktop";
            "application/x-bzip2" = "org.kde.ark.desktop";
            "application/x-xz" = "org.kde.ark.desktop";
            "application/zstd" = "org.kde.ark.desktop";
          };
        };
      };
    };
}
