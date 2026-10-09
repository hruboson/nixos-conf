{ self, inputs, ... }: {
  flake.nixosModules."user-hruon" =
    {
      pkgs,
      lib,
      config,
      username,
      ...
    }:
    let
      userMail = "hruboson@gmail.com";
      userName = "Ondřej Hruboš";

	  nextcloudLogin = "hruon";
	  nextcloudMachine = "nextcloud.hrubos.dev"; # nextcloud server
      nextcloudUrl = "https://${nextcloudMachine}";

      # local dir (relative to $HOME) -> remote dir on Nextcloud
      syncDirs = {
        pictures = {
          local = "Pictures";
          remote = "/Sync/Pictures";
        };
        # documents = { local = "Documents"; remote = "/Documents"; };
      };
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops # sops nix module
        inputs.secrets.nixosModules.default # sops password database
      ];

      users.groups.media = { }; # group for external drives that need both services and user access
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
          "media"
          "adbusers"
          "dialout"
        ];

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPjoRbd+2itXlw3mSVS7BfPj/SKVXME6Jvdk8IJCAddl" # tropikey pubkey
        ];
      };

	  nix.settings.trusted-users = [ "root" "${username}" ];

	  sops.secrets.nextcloud-sync.owner = username;
      sops.templates."netrc" = {
        content = ''
          machine ${nextcloudMachine}
          login ${nextcloudLogin}
          password ${config.sops.placeholder.nextcloud-sync}
        '';
        owner = username;
        mode = "0600";
		path = "/home/${username}/.netrc";
      };

      sops.secrets.hruon_priv_ssh_key = {
        owner = username;
        mode = "0400";
      };

      home-manager.users.${username} = {
        home.username = username;
        home.stateVersion = "26.05"; # set this to your current nixpkgs version and never change it

        programs.lazygit.enable = true;
        programs.git = {
          enable = true;
          settings = {
            credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
            user = {
              name = userName;
              email = userMail;
              init.defaultBranch = "main";
              pull.rebase = true;
            };
          };
        };

        programs.jujutsu = {
          enable = true;
          settings = {
            user = {
              name = userName;
              email = userMail;
            };
          };
        };

        programs.ssh = {
          enable = true;
          matchBlocks."*" = {
            identityFile = config.sops.secrets.hruon_priv_ssh_key.path;
            identitiesOnly = true;
          };
        };

        home.packages = with pkgs; [
          age
          sops
          ssh-to-age
          nextcloud-client

          (pkgs.writeShellApplication {
            name = "nextcloud-sync";
            runtimeInputs = [ pkgs.systemd ];
            text = /* bash */ ''
              known="${lib.concatStringsSep " " (lib.attrNames syncDirs)}"

              usage() {
                cat <<EOF
              Usage: nextcloud-sync [OPTIONS] [NAME ...]

              Sync folders with Nextcloud right now, using the same systemd
              units as the periodic timer and the file watcher.

              Options:
                -h, --help    Show this help and exit

              Arguments:
                NAME          Name of a sync entry. With no NAME, all entries are synced.

              Available names: $known

              Examples:
                nextcloud-sync              # sync everything
                nextcloud-sync pictures     # sync only "pictures"

              Logs: journalctl --user -u nextcloud-sync-NAME
              EOF
              }

              for arg in "$@"; do
                case "$arg" in
                  -h|--help) usage; exit 0 ;;
                esac
              done

              read -ra names <<< "$known"
              units=()

              if [ "$#" -gt 0 ]; then
                for n in "$@"; do
                  case " $known " in
                    *" $n "*) units+=("nextcloud-sync-$n.service") ;;
                    *) echo "Unknown name or option: $n" >&2; usage >&2; exit 2 ;;
                  esac
                done
              else
                for n in "''${names[@]}"; do units+=("nextcloud-sync-$n.service"); done
              fi

              status=0
              for u in "''${units[@]}"; do
                echo "==> $u"
                if systemctl --user start "$u"; then
                  echo "    done"
                else
                  echo "    FAILED, last log lines:"
                  journalctl --user -u "$u" -n 20 --no-pager || true
                  status=1
                fi
              done
              exit "$status"
            '';
          })
        ];

        # 1. In Nextcloud, go to Settings → Security → Devices & sessions and create an app password.
        # 2. Create ~/.netrc with chmod 600:
        #   machine cloud.example.com
        #   login yourusername
        #   password your-app-password
        # 3. Create the remote folder (e.g. /Sync/Pictures) in Nextcloud first, since nextcloudcmd expects it to exist.
        systemd.user.services = lib.mapAttrs' (
          name: cfg:
          lib.nameValuePair "nextcloud-sync-${name}" {
            Unit = {
              Description = "Sync ${cfg.local} with Nextcloud";
              After = [ "network-online.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = lib.escapeShellArgs [
                "${pkgs.nextcloud-client}/bin/nextcloudcmd"
                "--non-interactive"
                "-n" # read credentials from ~/.netrc
                "--path"
                cfg.remote
                "/home/${username}/${cfg.local}"
                nextcloudUrl
              ];
            };
          }
        ) syncDirs;

        systemd.user.timers = lib.mapAttrs' (
          name: _:
          lib.nameValuePair "nextcloud-sync-${name}" {
            Unit.Description = "Periodic Nextcloud sync (${name})";
            Timer = {
              OnBootSec = "1min";
              OnUnitActiveSec = "10min";
            };
            Install.WantedBy = [ "timers.target" ];
          }
        ) syncDirs;
      };
    };
}
