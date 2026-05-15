{ self, inputs, ... }: {
	flake.nixosModules.wlogout = { config, lib, pkgs, username, ... }: {
		config = {
			environment.systemPackages = with pkgs; [
				wlogout
			];

			home-manager.users.${username} = {
				wayland.windowManager.mango.settings.binds = [ 
					"SUPER,l,spawn_shell,wlogout"
				];

				programs.wlogout = {
					enable = true;
					layout = [
						{
							label = "lock";
							action = "loginctl lock-session";
							text = "Lock";
							keybind = "l";
						}
						{
							label = "logout";
							action = "loginctl terminate-session $XDG_SESSION_ID";
							text = "Logout";
							keybind = "e";
						}
						{
							label = "suspend";
							action = "systemctl suspend";
							text = "Suspend";
							keybind = "s";
						}
						{
							label = "Shutdown";
							action = "systemctl poweroff";
							text = "Shutdown";
							keybind = "q";
						}
						{
							label = "reboot";
							action = "systemctl reboot";
							text = "Reboot";
							keybind = "r";
						}
					];
					style = ''
						window {
							font-family: JetBrainsMono Nerd Font;
							font-size: 20pt;
							font-weight: bold;
							color: white; 
							background-color: rgba(20, 20, 21, 0.69);
						}

						#lock {
							background-image: image(url("./icons/lock.png"));
						}

						#logout {
							background-image: image(url("./icons/logout.png"));
						}

						/*#logout:hover {
							background-image: image(url("./icons/logout.png"));
						}*/

						#suspend {
							background-image: image(url("./icons/sleep.png"));
						} 

						#shutdown {
							background-image: image(url("./icons/power.png"));
						}

						#reboot {
							background-image: image(url("./icons/restart.png"));
						}

						/*#hibernate {
							background-image: image(url("./icons/hibernate.png"));
						}*/

						/*
						button {
							background-repeat: no-repeat;
							background-position: center;
							font-size: 40px;
							background-size: 60%;
							border: none;
							color: #d5b497;
							text-shadow: none;
							border-radius: 20px 20px 20px 20px;
							background-color: rgba(121, 81, 1, 0);
							margin-top: 120px;
							margin-bottom: 120px;
							transition: all 0.3s cubic-bezier(.55, 0.0, .28, 1.682), box-shadow 0.5s ease-in;
						}

						button:hover {
							background-color: rgba(184, 149, 80, 0.3);
							background-size: 80%;
							transition: all 0.3s cubic-bezier(.55, 0.0, .28, 1.682), box-shadow 0.5s ease-in;
						}
						*/
					'';
				};
			};
		};
	};
}
