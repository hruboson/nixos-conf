/**
 * Config based on Ekpap
 * YT video: https://www.youtube.com/watch?v=_8iTs_2mu0w
 */
{ self, inputs, ... }:
{
  flake.nixosModules.appPackKrita =
    { pkgs, username, ... }:
    {
      environment.systemPackages = [
        inputs.nixpkgs-krita5.legacyPackages.${pkgs.stdenv.hostPlatform.system}.krita
      ];

      home-manager.users.${username} =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfgDir = config.xdg.configHome;
          dataDir = config.xdg.dataHome;

          # false: only seed files that don't exist yet (Krita keeps your later tweaks)
          # true:  overwrite from the repo on every rebuild (fully declarative, like PhotoGIMP)
          resetOnRebuild = false;

          # Krita rewrites these files on exit, so they must be real, writable files
          # and NOT symlinks into the (read-only) nix store.
          installFile =
            src: dst:
            lib.optionalString (builtins.pathExists src) (
              if resetOnRebuild then
                ''install -Dm644 ${src} "${dst}"''
              else
                ''[ -e "${dst}" ] || install -Dm644 ${src} "${dst}"''
            );

          installDir =
            src: dst:
            lib.optionalString (builtins.pathExists src) ''
              mkdir -p "${dst}"
              cp -rT --no-preserve=mode,ownership ${lib.optionalString (!resetOnRebuild) "-n "}${src} "${dst}"
            '';

          plugins = [
            "tela"
            "theme_creator"
          ];

          brushes = [
            "d)_Ink_Pen_Texturized.kpp"
          ];

          installBrush =
            name:
            let
              src = builtins.path {
                path = ./brushes + "/${name}";
                name = lib.strings.sanitizeDerivationName name;
              };
              dst = lib.escapeShellArg "${dataDir}/krita/paintoppresets/${name}";
            in
            if resetOnRebuild then
              "install -Dm644 ${src} ${dst}"
            else
              "[ -e ${dst} ] || install -Dm644 ${src} ${dst}";
        in
        {
          xdg.dataFile = {
            "krita/pykrita/tela".source = "${inputs.krita-tela}/tela";
            "krita/pykrita/tela.desktop".source = "${inputs.krita-tela}/tela.desktop";

            "krita/pykrita/theme_creator".source = "${inputs.krita-theme-creator}/theme_creator";
            "krita/pykrita/theme_creator.desktop".source =
              "${inputs.krita-theme-creator}/theme_creator.desktop";
          }
          # Themes and workspaces: per-file symlinks, directory stays writable
          # so Theme Creator / "Save Workspace" can still add new files.
          // lib.optionalAttrs (builtins.pathExists ./krita/color-schemes) {
            "krita/color-schemes" = {
              source = ./krita/color-schemes;
              recursive = true;
            };
          }
          // lib.optionalAttrs (builtins.pathExists ./krita/workspaces) {
            "krita/workspaces" = {
              source = ./krita/workspaces;
              recursive = true;
            };
          };

          home.activation.kritaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            # Don't run this while Krita is open; it rewrites kritarc on exit.
            mkdir -p "${cfgDir}"

            ${installFile ./config/kritarc "${cfgDir}/kritarc"}
            ${installFile ./config/kritadisplayrc "${cfgDir}/kritadisplayrc"}
            ${installFile ./config/krita5.xmlgui "${dataDir}/kxmlgui5/krita/krita5.xmlgui"}
            ${installDir ./config/bundles "${dataDir}/krita/bundles"}

            ${lib.concatMapStringsSep "\n" installBrush brushes}

            # Always enforce "plugin enabled" flags, even if kritarc was seeded earlier.
            ${lib.concatMapStringsSep "\n" (p: ''
              ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
                --file "${cfgDir}/kritarc" --group python --key "enable_${p}" true \
                || echo "warning: could not enable Krita plugin ${p}"
            '') plugins}
          '';
        };
    };
}
