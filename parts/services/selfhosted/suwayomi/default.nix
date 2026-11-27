{ self, inputs, ... }: {
  flake.nixosModules.selfhostedSuwayomi =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      mangaDir = "/mnt/JARK/Manga/Suwayomi";
    in
    {
      systemd.tmpfiles.rules = [
        "d ${mangaDir}           0755 suwayomi suwayomi - -"
        "d ${mangaDir}/downloads 0755 suwayomi suwayomi - -"
      ];

      systemd.services.suwayomi-server.unitConfig.RequiresMountsFor = [ "/mnt/JARK" ];
      systemd.services.suwayomi-server.serviceConfig.ReadWritePaths = [ mangaDir ];

      sops.templates."suwayomi-env".content = ''
        SUWAYOMI_PASS=${config.sops.placeholder."suwayomi_pass"}
      '';

      systemd.services.suwayomi-server.serviceConfig.EnvironmentFile =
        config.sops.templates."suwayomi-env".path;

      services.suwayomi-server = {
        enable = true;
        openFirewall = true;

        settings = {
          server = {
            ip = "0.0.0.0";
            port = 4567;

            webUIEnabled = true;
            webUIFlavor = "WebUI"; # alternatives: "VUI", "Custom"
            initialOpenInBrowserEnabled = false; # headless server
            systemTrayEnabled = false;

            updateMangas = true; # autodownload
            globalUpdateInterval = 12; # hours, minimum is 6
            autoDownloadNewChapters = true;
            autoDownloadNewChaptersLimit = 0; # 0 = no limit per manga

			downloadsPath = mangaDir;
            downloadAsCbz = true;

            extensionRepos = [
              "https://github.com/keiyoushi/extensions/raw/repo/index.pb"
            ];

            authMode = "simple_login";
            authUsername = username;
            authPassword = "$SUWAYOMI_PASS";
          };
        };
      };

      selfhosted.services.suwayomi.port = 4567;
    };
}
