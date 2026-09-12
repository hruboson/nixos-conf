{ self, inputs, ... }: {
  flake.nixosModules.eliskaConfiguration =
    {
      pkgs,
      lib,
      hostname,
      username,
      ...
    }:
    {
      imports = [
        self.nixosModules.eliskaHardware
        self.nixosModules.eliskaSystem
        self.nixosModules.users

        self.nixosModules.desktopOptions
        self.nixosModules.mango
        self.nixosModules.kde

        self.nixosModules.kitty
        self.nixosModules.appPackDev
        self.nixosModules.appPackSysutils
        self.nixosModules.appPackDesktop
        self.nixosModules.appPack3D
        self.nixosModules.appPackDrawing
        self.nixosModules.appPackNetworking
        self.nixosModules.appPackSysutils
        self.nixosModules.appPackDesktop
        self.nixosModules.appPackGames
        self.nixosModules.appPackEducation

        self.nixosModules.servicesPackHomeserver
        self.nixosModules.servicesBluetooth
        self.nixosModules.servicesDisks
      ];

      # enable nix commands and flakes
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = "/home/${username}/nixos-conf"; # sets NH_OS_FLAKE
      };

      desktops.mango.monitors = ''
        monitorrule=name:eDP-1,width:2880,height:1800,refresh:60,x:0,y:0,scale:1.5
      '';
      desktops.lockscreen.background = pkgs.fetchurl {
        name = "ocean_dark_coral.jpg";
        url = "https://raw.githubusercontent.com/hruboson/wallpapers/refs/heads/main/ocean/ocean_dark_coral.jpg";
        hash = "sha256-7Am33XEVVREqtK+8eQU0kKSk05i6UmtUkqgYw6IqrZ0=";
      };

      desktops.lockscreen.profilePicture = pkgs.fetchurl {
        name = "hruon_logo.jpg";
        url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/logos/logos_inversion.png";
        hash = "sha256-7oa2vQaWmsQ+evWES1XNVBfI///McOv+J/9urFN1kEM=";
      };

      ## SOUND
      services.pulseaudio.enable = false;

      ## TOUCHPAD
      services.libinput.enable = true;

      # BUTTONS
      services.logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandlePowerKeyLongPress = "poweroff";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
      };

      # LOCALES
      console = {
        font = "Lat2-Terminus16";
        keyMap = "cz-qwertz";
      };
      time.timeZone = "Europe/Prague";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "cs_CZ.UTF-8";
        LC_IDENTIFICATION = "cs_CZ.UTF-8";
        LC_MEASUREMENT = "cs_CZ.UTF-8";
        LC_MONETARY = "cs_CZ.UTF-8";
        LC_NAME = "cs_CZ.UTF-8";
        LC_NUMERIC = "cs_CZ.UTF-8";
        LC_PAPER = "cs_CZ.UTF-8";
        LC_TELEPHONE = "cs_CZ.UTF-8";
        LC_TIME = "cs_CZ.UTF-8";
      };

      # NETWORK
      #networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
      networking.firewall.enable = true;

      # Enable the OpenSSH daemon and ssh-agent with keys
      services.openssh.enable = true;
      programs.ssh.startAgent = true;

      # MISC
      programs.nix-ld.enable = true;

      # if build is too slow change this line to nix.optimise.automatic = true;
      nix.settings.auto-optimise-store = true; # optimise /nix/store space

      # garbage collector
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
    };
}
