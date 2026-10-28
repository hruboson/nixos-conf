{ self, inputs, ... }: {
  flake.nixosModules.selfhostedThesis = { config, lib, pkgs, username, ... }:
    let
      cfg = config.selfhosted.services.thesis;
      thesis = config.selfhosted.thesis;

      # site.html + server.py live next to this file and are copied into the store
      app = pkgs.runCommand "thesis-app" { } ''
        mkdir -p $out
        cp ${./server.py} $out/server.py
        cp ${./site.html} $out/site.html
        cp -r ${./fonts} $out/fonts
      '';
    in
    {
      options.selfhosted.thesis = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Run the thesis textbook server (enabled as soon as the module is imported).";
        };

        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/thesis";
          description = "Where progress and notes are stored.";
        };
      };

      config = lib.mkIf thesis.enable {
        selfhosted.services.thesis.port = 9999;

        users.users.thesis = {
          isSystemUser = true;
          group = "thesis";
        };
        users.groups.thesis = { };

        systemd.tmpfiles.rules = [ "d ${thesis.dataDir} 0750 thesis thesis -" ];

        systemd.services.thesis = {
          description = "Thesis textbook server";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          environment = {
            THESIS_HOST = "127.0.0.1"; # only caddy talks to it
            THESIS_PORT = toString cfg.port;
            THESIS_DATA_DIR = thesis.dataDir;
            THESIS_SITE = "${app}/site.html";
            PYTHONUNBUFFERED = "1";
          };

          serviceConfig = {
            ExecStart = "${pkgs.python3}/bin/python3 ${app}/server.py";
            Restart = "always";
            RestartSec = 3;
            User = "thesis";
            Group = "thesis";

            # hardening
            ReadWritePaths = [ thesis.dataDir ];
            ProtectSystem = "strict";
            ProtectHome = "read-only";
            NoNewPrivileges = true;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
            RestrictNamespaces = true;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            RestrictRealtime = true;
            SystemCallArchitectures = "native";
          };
        };
      };
    };
}

