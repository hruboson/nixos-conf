{ self, inputs, ... }: {
  flake.nixosModules.selfhostedYoutarr =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      externalDir = "/mnt/JARK/Movies/Youtube/";
    in
    {
      imports = [ inputs.youtarr-flake.nixosModules.default ];

      sops = {
        secrets."youtarr_db_pass".owner = "mysql";
        templates = {
          "youtarr-auth.env".content = ''
            AUTH_PRESET_PASSWORD=${config.sops.placeholder."youtarr_admin_pass"}
          '';

          "youtarr-db.env".content = ''
            DB_PASSWORD=${config.sops.placeholder."youtarr_db_pass"}
          '';
        };
      };

      services.mysql = {
        enable = true;
        package = pkgs.mariadb;

        ensureDatabases = [ "youtarr" ];
        ensureUsers = [
          {
            name = "youtarr";
            ensurePermissions = {
              "youtarr.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

      # set the mariadb users (mariadb youtarr) password declaratively
      systemd.services.youtarr-db-setup = {
        description = "Set Youtarr MariaDB user password";
        after = [ "mysql.service" ];
        requires = [ "mysql.service" ];
        before = [ "youtarr.service" ];
        requiredBy = [ "youtarr.service" ];
        path = [ config.services.mysql.package ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "root";
        };
        script = ''
          pw=$(cat ${config.sops.secrets."youtarr_db_pass".path})
          mysql <<EOF
          CREATE USER IF NOT EXISTS 'youtarr'@'localhost' IDENTIFIED BY '$pw';
          CREATE USER IF NOT EXISTS 'youtarr'@'127.0.0.1' IDENTIFIED BY '$pw';
          ALTER USER 'youtarr'@'localhost' IDENTIFIED BY '$pw';
          ALTER USER 'youtarr'@'127.0.0.1' IDENTIFIED BY '$pw';
          GRANT ALL ON youtarr.* TO 'youtarr'@'localhost';
          GRANT ALL ON youtarr.* TO 'youtarr'@'127.0.0.1';
          FLUSH PRIVILEGES;
          EOF
        '';
      };

      systemd.tmpfiles.rules = [
        "d ${externalDir} 0775 youtarr media - -"
      ];

      services.youtarr = {
        enable = true;
        port = 9078;
        youtubeOutputDir = externalDir;

        auth = {
          enable = true;
          presetUsername = username;
          presetPasswordFile = config.sops.templates."youtarr-auth.env".path;
        };

        database = {
          host = "127.0.0.1";
          user = "youtarr";
          name = "youtarr";
          passwordFile = config.sops.templates."youtarr-db.env".path;
        };

        # declaratively manage Youtarr's global preferences
        settings = {
          preferredResolution = "720";
          channelAutoDownload = true;
          channelDownloadFrequency = "0 */6 * * *"; # check every 6 hours
          writeVideoNfoFiles = true;
          sponsorblockEnabled = true;
          sponsorblockAction = "remove";

          subtitlesEnabled = true;
          subtitlesLanguage = "en";
        };
      };

      selfhosted.services.youtarr.port = 9078;
    };
}
