{ self, inputs, ... }: {
  flake.nixosModules.appPackGames =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      imports = [
        self.nixosModules.gamesExeTool
      ];

      environment.systemPackages =
        with pkgs;
        let
          heroicWithExtras = pkgs.heroic.override {
            extraPkgs =
              pkgs': with pkgs'; [
                gamescope
                gamemode
                wineWow64Packages.stable
                winetricks
              ];
          };
        in
        [
          prismlauncher # minecraft foss launcher
          osu-lazer-bin # click the circles
          heroicWithExtras # epic games + steam + gog in one app
          lutris # Windows games emulator
          bottles # can run windows games if you have the .exe file
          protontricks # install winetricks verbs (vcrun, dotnet, etc) into a game's proton prefix

          libretro.beetle-psx-hw # possible ps5 controller fix

          pcsx2 # PS2 emulator
          (retroarch.withCores (
            cores: with cores; [
              beetle-psx-hw # PS1 emulator
              dosbox-pure # DOS emulator
              dolphin # Gamecube emulator
            ]
          ))

          wayvr # VR
        ];

      programs.gamemode.enable = true;
      programs.gamescope.enable = true;
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];

        # VR settings
        package = lib.mkDefault (
          pkgs.steam.override (prev: {
            extraEnv = {
              PRESSURE_VESSEL_FILESYSTEMS_RW = "$XDG_RUNTIME_DIR/wivrn/comp_ipc";
            }
            // (prev.extraEnv or { });
          })
        );
      };
      hardware.steam-hardware.enable = true;
      hardware.xone.enable = true;

      # VR
      services.wivrn = {
        enable = true;
        openFirewall = true; # Required for wireless streaming
        highPriority = true;
        steam.enable = true;
      };

      home-manager.users.${username} =
        {
          config,
          osConfig,
          pkgs,
          ...
        }:
        {
          # File types -> app associations
          # mimetype.io/all-types
          xdg.mimeApps = {
            enable = true;
            defaultApplications = {

            };
          };
        };
    };
}
