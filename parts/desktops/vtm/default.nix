{ self, inputs, ... }: {
  flake.nixosModules.vtm =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        vtm

        browsh
      ];

      console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz";
        keyMap = "cz-qwertz";
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            # border=yellow;text=cyan;prompt=cyan;time=yellow;input=yellow;container=black;button=cyan;title=yellow
			command = ''${pkgs.tuigreet}/bin/tuigreet --time --theme "border=yellow;text=cyan" --remember --remember-session --cmd "vtm --run term zsh"'';
            user = "greeter";
          };
        };
      };

      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYPath = "/dev/tty1";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
    };
}
