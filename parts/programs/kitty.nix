{ self, inputs, ... }: {
	flake.nixosModules.kitty = { pkgs, lib, username, ... }:
	let
		home = { pkgs, lib, ... }: {
			programs.zsh = {
				enable = true;
				autosuggestion.enable = true;
				syntaxHighlighting.enable = true;
				historySubstringSearch.enable = true;

				history = {
					size = 10000;
					save = 10000;
					ignoreDups = true;
					ignoreSpace = true;
					share = true;
				};

			    autocd = true;

			    setOptions = [
			    	"NO_BEEP"           # Don't beep on errors
			    	"NO_HUP"            # Don't kill background jobs on logout
			    	"NO_CHECK_JOBS"     # Don't warn about background jobs
			    	"NO_NOMATCH"        # Don't report no matches
			    	"NO_RM_STAR_SILENT" # Ask before rm *
			    	"INTERACTIVE_COMMENTS"  # Allow comments in interactive shell
			    ];

				initContent = lib.mkOrder 550 ''
					# Kitty shell integration (fallback in case HM doesn't cover edge cases)
					if test -n "$KITTY_INSTALLATION_DIR"; then
						export KITTY_SHELL_INTEGRATION="enabled"
						autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
						kitty-integration
						unfunction kitty-integration
					fi

					if command -v kitty &>/dev/null; then
						alias ssh="kitty +kitten ssh"
					fi

					PS1="[%n@%m %1~] "
				'';

				shellAliases = {
					# Kitty image/diff kitten aliases
					icat = "kitty +kitten icat";
					kdiff = "kitty +kitten diff";
				};
			};

			programs.kitty = {
				enable = true;
				enableGitIntegration = true;
				shellIntegration.enableZshIntegration = true;
				font = {
					name = "FiraCode Nerd Font Mono";
					package = pkgs.nerd-fonts.fira-code;
					size = 12;
				};
				settings = {
					linux_display_server = "wayland";
					dynamic_background_opacity = true;
					remember_window_size = true;
					bold_font = "auto";
					italic_font = "auto";
					bold_italic_font = "auto";
					confirm_os_window_close = "0";
					disable_ligatures = "always";
				};
				keybindings = {
					"ctrl+backspace" = "send_text all \\x17";
				};
				themeFile = "vague";
			};
		};
	in {
		programs.zsh.enable = true;
		users.users.${username}.shell = pkgs.zsh;
		home-manager.users.${username} = home;
	};
}
