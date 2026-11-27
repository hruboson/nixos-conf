{ self, inputs, ... }: {
  flake.nixosModules.gamesExeTool =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      exe-tool = pkgs.writeShellApplication {
        name = "exe-tool";
        runtimeInputs = with pkgs; [
          coreutils
          findutils
          gnused
          gnugrep
          jq
          libnotify
          xdg-utils
          xdg-user-dirs
          icoutils
          umu-launcher
          kdePackages.kdialog
        ];
        excludeShellChecks = [
          "SC2155"
          "SC2086"
          "SC1090"
        ];
        text = builtins.readFile ./exe-tool.sh;
      };

      mimes = [
        "application/x-ms-dos-executable"
        "application/vnd.microsoft.portable-executable" # newer shared-mime-info name
        "application/x-msi"
        "application/x-bat"
      ];

      runHandler = pkgs.makeDesktopItem {
        name = "exe-tool-run";
        desktopName = "Run Windows program";
        exec = "exe-tool run %f";
        icon = "wine";
        mimeTypes = mimes;
        noDisplay = true;
      };

      serviceMenu = pkgs.writeTextFile {
        name = "exe-tool-servicemenu";
        destination = "/share/kio/servicemenus/exe-tool.desktop";
        executable = true; # Plasma ignores non-executable service menus
        text = ''
          [Desktop Entry]
          Type=Service
          MimeType=${builtins.concatStringsSep ";" mimes};
          Actions=shortcut;heroic;mango;winecfg;winetricks;prefix;kill;
          X-KDE-Submenu=Windows game
          Icon=wine

          [Desktop Action shortcut]
          Name=Create desktop shortcut + menu entry
          Icon=emblem-link
          Exec=exe-tool shortcut %f

          [Desktop Action heroic]
          Name=Add to Heroic Games Launcher
          Icon=heroic
          Exec=exe-tool heroic %f

          [Desktop Action mango]
          Name=Run with MangoHud overlay
          Icon=speedometer
          Exec=exe-tool mango %f

          [Desktop Action winecfg]
          Name=Wine configuration (winecfg)
          Icon=configure
          Exec=exe-tool winecfg %f

          [Desktop Action winetricks]
          Name=Install components (winetricks)
          Icon=system-software-install
          Exec=exe-tool winetricks %f

          [Desktop Action prefix]
          Name=Open prefix folder
          Icon=folder-open
          Exec=exe-tool prefix %f

          [Desktop Action kill]
          Name=Kill all Wine processes
          Icon=process-stop
          Exec=exe-tool kill %f
        '';
      };
    in
    {
      environment.systemPackages = [
        exe-tool
        runHandler
        serviceMenu
        pkgs.umu-launcher
        pkgs.mangohud
        pkgs.gamemode
      ];
      environment.pathsToLink = [ "/share/kio" ];

      xdg.mime.defaultApplications = builtins.listToAttrs (
        map (m: {
          name = m;
          value = "exe-tool-run.desktop";
        }) mimes
      );

      hardware.graphics.enable32Bit = true; # (hardware.opengl.driSupport32Bit on older releases)
      programs.gamemode.enable = true;
    };
}
