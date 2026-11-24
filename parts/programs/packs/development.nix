{ self, inputs, ... }: {
  flake.nixosModules.appPackDev =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      imports = [
        self.nixosModules.nvim
        inputs.nix-index-database.nixosModules.nix-index
      ];

      environment.systemPackages = with pkgs; [
        bat

        gh
        libgcc
        neovide
        filezilla
        mc

        jujutsu
        lazyjj

        poedit

        hydra-check
        devenv
      ];

      virtualisation.docker.enable = true;
      programs.nix-index-database.comma.enable = true;
      environment.shellAliases.mc = "mc --nosubshell";

      home-manager.users.${username} = {
        programs.lazygit.enable = true;
        programs.git = {
          enable = true;
          lfs.enable = true;
          /*
            Add settings in your user module
            settings = { ... };
          */
        };
		
        # Midnight Commander: vim-like setup
        xdg.configFile."mc/ini" = {
          force = true;
          text = ''
            [Midnight-Commander]
            # F4 opens $EDITOR (nvim) instead of mcedit
            use_internal_edit=false
            use_internal_view=true
            # h/l (Left/Right) go to parent / enter directory
            navigate_with_arrows=true
            auto_save_setup=false
            confirm_exit=false
            show_hidden=true

            [Layout]
            keybar_visible=false
          '';
        };

        xdg.configFile."mc/mc.keymap" = {
          force = true;
          text = ''
            [panel]
            Down = down; j
            Up = up; k
            Left = left; h
            Right = right; l
            Top = home; g
            Bottom = end; G
            PageDown = pgdn; ctrl-f; ctrl-d
            PageUp = pgup; ctrl-b; ctrl-u
            Search = ctrl-s; slash
            Mark = insert; v
            Edit = f4; e
            View = f3; i
            Quit = f10; q

            [viewer]
            Down = down; j
            Up = up; k
            Left = left; h
            Right = right; l
            Top = home; g
            Bottom = end; G
            PageDown = pgdn; ctrl-f; ctrl-d; space
            PageUp = pgup; ctrl-b; ctrl-u
            Search = f7; slash
            SearchBackward = question
            SearchContinue = n
            SearchContinueBackward = N
            Quit = f10; q; esc

            [listbox]
            Down = down; j; ctrl-n
            Up = up; k; ctrl-p
            Top = home; g
            Bottom = end; G

            [help]
            Down = down; j
            Up = up; k
            PageDown = pgdn; ctrl-f; space
            PageUp = pgup; ctrl-b
            Top = home; g
            Bottom = end; G
            Quit = f10; q; esc
          '';
        };

        # File types -> app associations
        # mimetype.io/all-types
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/plain" = "neovide.desktop";
            "application/x-zerosize" = "neovide.desktop";
          };
        };
      };
    };
}
