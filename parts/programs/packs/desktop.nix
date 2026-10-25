{ self, inputs, ... }: {
  flake.nixosModules.appPackDesktop =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = config.nixpkgs.config;
      };
    in
    {
      imports = [
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        with pkgs;
        let
          application-menu = pkgs.runCommandLocal "xdg-application-menu" { } ''
            mkdir -p $out/etc/xdg/menus/
            ln -s ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu \
            $out/etc/xdg/menus/applications.menu
          '';

          oculante-wrapped = pkgs.symlinkJoin {
            name = "oculante";
            paths = [ pkgs-unstable.oculante ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/oculante --set WINIT_UNIX_BACKEND x11
            '';
          };
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
          oculante-wrapped
          gthumb
          vlc
          spotify
          quodlibet
          (pkgs.wrapOBS {
            plugins = with pkgs.obs-studio-plugins; [ wlrobs ];
          })

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
          thorium-reader
          yacreader

          # other
          gnome-software
          kdePackages.kamoso # camera app

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

          openconnect
        ];

      # enable flatpak (for both imperative and declarative installs -- sure, go for it)
      services.flatpak = {
        enable = true;
        packages = [
          "net.waterfox.waterfox"
        ];
      };

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
            "text/html" = "net.waterfox.waterfox.desktop";
            "x-scheme-handler/http" = "net.waterfox.waterfox.desktop";
            "x-scheme-handler/https" = "net.waterfox.waterfox.desktop";
            "x-scheme-handler/about" = "net.waterfox.waterfox.desktop";
            "x-scheme-handler/unknown" = "net.waterfox.waterfox.desktop";

            # Documents
            "application/pdf" = "net.waterfox.waterfox.desktop";
            "text/markdown" = "net.waterfox.waterfox.desktop";
            "application/epub+zip" = "thorium.desktop";

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

            # LibreOffice Writer (text documents)
            "application/vnd.oasis.opendocument.text" = "writer.desktop";
            "application/vnd.oasis.opendocument.text-template" = "writer.desktop";
            "application/msword" = "writer.desktop";
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
            "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "writer.desktop";
            "application/rtf" = "writer.desktop";
            "text/rtf" = "writer.desktop";

            # LibreOffice Calc (spreadsheets)
            "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
            "application/vnd.oasis.opendocument.spreadsheet-template" = "calc.desktop";
            "application/vnd.ms-excel" = "calc.desktop";
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
            "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "calc.desktop";
            "text/csv" = "calc.desktop";

            # LibreOffice Impress (presentations)
            "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
            "application/vnd.oasis.opendocument.presentation-template" = "impress.desktop";
            "application/vnd.ms-powerpoint" = "impress.desktop";
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
            "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = "impress.desktop";

            # LibreOffice Draw / Math / Base
            "application/vnd.oasis.opendocument.graphics" = "draw.desktop";
            "application/vnd.visio" = "draw.desktop";
            "application/vnd.oasis.opendocument.formula" = "math.desktop";
            "application/vnd.oasis.opendocument.database" = "base.desktop";

            # Comics
            "application/vnd.comicbook+zip" = "YACReader.desktop"; # .cbz
            "application/vnd.comicbook-rar" = "YACReader.desktop"; # .cbr
            "application/x-cbz" = "YACReader.desktop";
            "application/x-cbr" = "YACReader.desktop";
            "application/x-cb7" = "YACReader.desktop"; # .cb7
            "application/x-cbt" = "YACReader.desktop"; # .cbt
          };
        };
      };
    };
}
