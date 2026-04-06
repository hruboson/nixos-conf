{ self, inputs, ... }: {
	flake.nixosModules.mango = { config, lib, pkgs, username, ... }: let
		wallpaper = pkgs.fetchurl {
			name = "kita.png";
			url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/gruvbox/kita.png";
			hash = "sha256-Q4xal1LPSc+UBSgodufcOJ0JyKQj61WT+4osYwdNntA=";
		};
	in {
		imports = [
			inputs.mango.nixosModules.mango
			inputs.silentSDDM.nixosModules.default

			self.nixosModules.waybar
			self.nixosModules.darkmode
		];

		options.desktops.mango = {
			monitors = lib.mkOption {
				type = lib.types.str;
				description = "Mango monitor configuration";
			};
		};

		config = {
			programs.mango.enable = true;
			programs.dconf.enable = true;
			security.polkit.enable = true;
			services.dbus.enable = true;
			hardware.graphics.enable = true;

			xdg.portal.enable = true;
			xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

			services.displayManager.sddm.enable = true;
			programs.silentSDDM = {
				enable = true;
				theme = "default";
				backgrounds = {
					wallpaper = pkgs.fetchurl {
						name = "water.jpg";
						url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/fruitiger_aero/drop.jpg";
						hash = "sha256-82eyZ5MgykxnxKP1aoHEXjRXTLXTbb9HxIT1eC24dDY=";
					};
				};
				settings = {
					"LoginScreen" = { background = "water.jpg"; blur = 5; };
					"LockScreen"  = { background = "water.jpg"; blur = 5; };
					"General"     = { background-fill-mode = "fill"; };
				};
				profileIcons = {
					${username} = pkgs.fetchurl {
						name = "hruon_logo.jpg";
						url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/logos/inversion.png";
						hash = "sha256-7oa2vQaWmsQ+evWES1XNVBfI///McOv+J/9urFN1kEM=";
					};
				};
			};

			fonts.packages = with pkgs; [
				nerd-fonts.fira-code
				nerd-fonts.jetbrains-mono
				vista-fonts
			];

			environment.systemPackages = (with pkgs; [
				killall
				wev
				wayland
				wlr-randr
				wdisplays
				vicinae
				quickshell
				qt6.qtwayland
				grim
				slurp
				pwvucontrol
				pulseaudio
				playerctl
				inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
			]);

			desktops.waybar = {
				enable = true;
				style = ''
					@define-color bg_hover rgba(200, 200, 200, 0.3);
					@define-color bg_back rgba(0, 0, 0, 0.3);
					@define-color content_main white;

					* {
						font-family: "FiraCode Nerd Font Mono";
						font-weight: bold;
						font-size: 13px;
						background-color: transparent;
						min-height: 0;
					}

					window#waybar {
						background-color: @bg_back;
						padding-top: 1px;
						padding-bottom: 1px;
						margin-top: 0px;
						margin-bottom: 0px;
					}

					#clock, #pulseaudio, #mpris {
						color: white;
					}

					#clock {
						padding-right: 10px;
					}

					#workspaces {

					}

					#workspaces button {
						color: white;
					}

					#workspaces button.hidden {

					}

					#workspaces button.visible {
						color: #ddca9e;
					}

					#workspaces button:hover {
						color: #d79921;
					}

					#workspaces button.active {
						color: black;
						background-color: #ddca9e;
					}

					#workspaces button.urgent {
						background-color: #ef5e5e;
					}

					#tags {
						background-color: transparent;
					}

					#tags button {
						background-color: #fff;
					}

					#tags button:not(.occupied):not(.focused) {
						color: transparent;
						background-color: transparent;
					}

					#tags button.occupied {
						background-color: #fff;
					}

					#tags button.focused {
						background-color: rgb(186, 142, 213);
					}

					#tags button.urgent {
						background: rgb(171, 101, 101);
					}

					#window {
						background-color: rgb(237, 196, 147);
					}

					#custom-os_button {
						font-family: "JetBrainsMono Nerd Font";
						font-size: 18px;
						padding-left: 12px;
						padding-right: 20px;
						transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
					}

					#custom-os_button:hover, #custom-portals_button:hover {
						background:  @bg_hover;
						color: @content_main;
					}
					
					#pulseaudio {
						font-family: "JetBrainsMono Nerd Font";
						padding-left: 3px;
						padding-right: 3px;
						transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
					}

					#pulseaudio:hover {
						background: @bg_hover;
					}

					#cpu, #disk, #memory {
						padding:3px;
					}
					#tray{
						margin-left: 5px;
						margin-right: 5px;
					}
					#tray > .passive {
						border-bottom: none;
					}
					#tray > .active {
						border-bottom: 3px solid white;
					}
					#tray > .needs-attention {
						border-bottom: 3px solid @warning_color;
					}
					#tray > widget {
						transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
					}
					#tray > widget:hover {
						background: @bg_hover;
					}
				'';
				config = {
					layer = "top";
					position = "bottom";
					height = 15;
					modules-left = [ "custom/os_button" "ext/workspaces" "wlr/taskbar" ];
					modules-center = [ "mpris" ];
					modules-right = [ 
						"cpu"
						"temperature"
						"disk"
						"tray"
						"pulseaudio"
						"network"
						"battery"
						"clock"
					];

					"ext/workspaces" = {
						format = "{icon}";
						ignore-hidden = true;
						on-click = "activate";
						on-click-right = "deactivate";
						sort-by-id = true;
					};

					"wlr/taskbar" = {
						format = "{icon}";
						icon-size = 18;
						spacing = 3;
						on-click-middle = "close";
						tooltip-format = "{title}";
						ignore-list = [];
						on-click = "activate";
					};

					/*"dwl/window" = {
						format = "[{layout}] {title}";
					};*/

					mpris = {
						format = "{player_icon}   {title}";
						format-paused = "{status_icon}   {title}";
						tooltip-format = "{player} - {title} by {artist}";
						truncate = 30;
						ellipsis = true;
						player-icons = {
							default = "🎵";
							spotify = "";
							firefox = "";
							chromium = "";
							mpv = "";
							vlc = "󰕼";
						};
						status-icons = {
							playing = "";
							paused = "";
							stopped = "";
						};

						on-click = "playerctl play-pause";
						on-click-right = "playerctl next";
						on-click-middle = "playerctl previous";
						on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
						on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
						ignored-players = [ "" ];  # ignore specific players
						interval = 1;  # update every second
						max-length = 50;
					};

					clock = {
						format = "{:%R %d.%m.%Y}";
						tooltip-format = "<tt><small>{calendar}</small></tt>";
						calendar = {
							mode = "year";
							mode-mon-col = 3;
							weeks-pos = "right";
							on-scroll = 1;
							on-click-right = "mode";
							format = {
								months = "<span color='#ffead3'><b>{}</b></span>";
								days = "<span color='#ecc6d9'><b>{}</b></span>";
								weeks = "<span color='#99ffdd'><b>W{}</b></span>";
								weekdays = "<span color='#ffcc66'><b>{}</b></span>";
								today = "<span color='#ff6699'><b><u>{}</u></b></span>";
							};
						};
						actions = {
							on-click-right = "mode";
							on-click-forward = "tz_up";
							on-click-backward = "tz_down";
							on-scroll-up = "shift_up";
							on-scroll-down = "shift_down";
						};
					};

					cpu = {
						interval = 5;
						format = " {usage}% ";
						max-length = 10;
					};

					temperature = {
						hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
						input-filename = "temp2_input";
						critical-threshold = 75;
						tooltip = false;
						format-critical = "({temperatureC}°C)";
						format = "({temperatureC}°C)";
					};

					disk = {
						interval = 30;
						format = "󰋊 {percentage_used}% ";
						path = "/";
						tooltip = true;
						unit = "GB";
						tooltip-format = "Available {free} of {total}";
					};

					tray = {
						icon-size = 18;
						spacing = 3;
					};

					network = {
						format-wifi = " {icon} ";
						format-ethernet = "  ";
						format-disconnected = "󰌙";
						format-icons = [ "󰤯 " "󰤟 " "󰤢 " "󰤢 " "󰤨 " ];
					};
					
					battery = {
						format = "{capacity}% {icon}";
						states = {
							warning = 30;
							critical = 15;
						};
					};
					
					pulseaudio = {
						max-volume = 150;
						scroll-step = 5;
						format = "{icon}";
						tooltip-format = "{volume}%";
						format-muted = " ";
						format-icons = {
							default = [
								" "
								" "
								" "
							];
						};
						"on-click" = "pavucontrol";
					};

					"custom/os_button" = {
						format = "";
						on-click = "vicinae toggle";
						tooltip = false;
					};
				};
			};

			home-manager.users.${username} = {
				imports = [ inputs.mango.hmModules.mango ];

				home.pointerCursor = let 
					getFrom = url: hash: name: {
						gtk.enable = true;
						x11.enable = true;
						name = name;
						size = 48;
						package = 
							pkgs.runCommand "moveUp" {} ''
							mkdir -p $out/share/icons
							ln -s ${pkgs.fetchzip {
								url = url;
								hash = hash;
							}} $out/share/icons/${name}
						'';
					};
				in
					getFrom 
					"https://github.com/polirritmico/Breeze-Dark-Cursor/releases/download/v1.0/Breeze_Dark_v1.0.tar.gz"
					"sha256-FgqS3rHJ4o5x4ONSaDZlQu1sFhefhWPk8vaBvURKZzY=" # get this hash by running nix store prefetch-file https://github/cursortheme/theme.tar.gz ... if this hash is wrong you wont be able to rebuild the system
					"Breeze-Dark";

				wayland.windowManager.mango = {
					enable = true;

					extraConfig = lib.strings.trim config.desktops.mango.monitors;

					settings = {
						/*
						 * LAYOUTS
						 */

						# Scroller Layout
						scroller_structs = 10;
						scroller_default_proportion = 0.40;
						scroller_focus_center = 1;
						scroller_prefer_center = 1;
						edge_scroller_pointer_focus = 1;
						scroller_ignore_proportion_single = 0;
						scroller_default_proportion_single = 1.0;

						# Master-Stack Layout
						new_is_master = 0;
						smartgaps = 0;
						default_mfact = 0.55;
						default_nmaster = 1;

						# Overview
						hotarea_size = 10;
						enable_hotarea = 1;
						ov_tab_mode = 0;
						overviewgappi = 5;
						overviewgappo = 30;

						tagrule = [
							# Virtual
							"id:1,monitor_name:Virtual-1,layout_name:deck"
							"id:2,monitor_name:Virtual-1,layout_name:scroller"
							"id:3,monitor_name:Virtual-1,layout_name:grid"
							# DP-2
							"id:1,monitor_name:DP-2,layout_name:deck"
							"id:2,monitor_name:DP-2,layout_name:deck"
							"id:3,monitor_name:DP-2,layout_name:deck"
							"id:4,monitor_name:DP-2,layout_name:deck"
							"id:5,monitor_name:DP-2,layout_name:deck"
							"id:6,monitor_name:DP-2,layout_name:deck"
							"id:7,monitor_name:DP-2,layout_name:deck"
							"id:8,monitor_name:DP-2,layout_name:deck"
							"id:9,monitor_name:DP-2,layout_name:deck"
							# HDMI-A-1
							"id:1,monitor_name:HDMI-A-1,layout_name:deck"
							"id:2,monitor_name:HDMI-A-1,layout_name:deck"
							"id:3,monitor_name:HDMI-A-1,layout_name:deck"
							"id:4,monitor_name:HDMI-A-1,layout_name:deck"
							"id:5,monitor_name:HDMI-A-1,layout_name:deck"
							"id:6,monitor_name:HDMI-A-1,layout_name:deck"
							"id:7,monitor_name:HDMI-A-1,layout_name:deck"
							"id:8,monitor_name:HDMI-A-1,layout_name:deck"
							"id:9,monitor_name:HDMI-A-1,layout_name:deck"
							# HDMI-A-2 (vertical scroller)
							"id:1,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:2,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:3,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:4,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:5,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:6,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:7,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:8,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
							"id:9,monitor_name:HDMI-A-2,layout_name:vertical_scroller"
						];

						repeat_rate = 25;
						repeat_delay = 600;
						numlockon = 1;
						xkb_rules_layout = "cz";
						xkb_rules_options = "grp:alt_shift_toggle";

						# Trackpad
						disable_trackpad = 0;
						tap_to_click = 1;
						tap_and_drag = 1;
						drag_lock = false;
						mouse_natural_scrolling = 0;
						trackpad_natural_scrolling = 0;
						disable_while_typing = 1;
						left_handed = 0;
						middle_button_emulation = 0;
						swipe_min_threshold = 1;
						accel_profile = 2;
						accel_speed = 0.0;

						mousebind = [
							"SUPER,btn_left,moveresize,curmove"
							"SUPER,btn_right,moveresize,curresize"
							"SUPER+CTRL,btn_right,killclient"
						];

						bind = [
							"SUPER,r,reload_config"
							"SUPER,Return,spawn,kitty"
							"SUPER,space,spawn,vicinae toggle"
							"SUPER,v,spawn,vicinae vicinae://extensions/vicinae/clipboard/history"

							"ALT,Tab,toggleoverview,0"

							# vertical_scroller
							"SUPER,Up,focusdir,up"
							"SUPER,Down,focusdir,down"
							"SUPER,equal,set_proportion,+0.1"
							"SUPER,minus,set_proportion,-0.1"

							# windows
							"SUPER,Right,focusstack,next"
							"SUPER,Left,focusstack,prev"
							"SUPER+SHIFT,Up,exchange_client,up"
							"SUPER+SHIFT,Down,exchange_client,down"
							"SUPER+SHIFT,Left,exchange_client,left"
							"SUPER+SHIFT,Right,exchange_client,right"
							"SUPER+SHIFT,q,killclient"

							# monitor nav
							"SUPER+CTRL,Left,focusmon,left"
							"SUPER+CTRL,Right,focusmon,right"

							# tag nav
							"SUPER,1,view,1,0"
							"SUPER,2,view,2,0"
							"SUPER,3,view,3,0"
							"SUPER,4,view,4,0"
							"SUPER,5,view,5,0"
							"SUPER,6,view,6,0"
							"SUPER,7,view,7,0"
							"SUPER,8,view,8,0"
							"SUPER,9,view,9,0"
							"SUPER+SHIFT,1,tag,1,0"
							"SUPER+SHIFT,2,tag,2,0"
							"SUPER+SHIFT,3,tag,3,0"
							"SUPER+SHIFT,4,tag,4,0"
							"SUPER+SHIFT,5,tag,5,0"
							"SUPER+SHIFT,6,tag,6,0"
							"SUPER+SHIFT,7,tag,7,0"
							"SUPER+SHIFT,8,tag,8,0"
							"SUPER+SHIFT,9,tag,9,0"
						];

						axisbind = [
							"SUPER,UP,focusdir,up"
							"SUPER,DOWN,focusdir,down"
						];

						gappih = 5;
						gappiv = 5;
						gappoh = 5;
						gappov = 5;
						scratchpad_width_ratio = 0.8;
						scratchpad_height_ratio = 0.9;
						borderpx = 0;
						rootcolor = "0x201b14ff";
						bordercolor = "0x444444ff";
						focuscolor = "0x8BAA9Bff";
						maximizescreencolor = "0xBABD2Cff";
						urgentcolor = "0xad401fff";
						scratchpadcolor = "0xc4939dff";
						globalcolor = "0x8d64cfff";
						overlaycolor = "0x95C381ff";

						# Blur
						blur = 0;
						blur_layer = 1;
						blur_optimized = 1;
						blur_params_num_passes = 2;
						blur_params_radius = 5;
						blur_params_noise = 0.02;
						blur_params_brightness = 0.9;
						blur_params_contrast = 0.9;
						blur_params_saturation = 1.2;

						# Shadows
						shadows = 1;
						layer_shadows = 1;
						shadow_only_floating = 1;
						shadows_size = 12;
						shadows_blur = 15;
						shadows_position_x = 0;
						shadows_position_y = 0;
						shadowscolor = "0x000000ff";

						# Rounding / opacity
						border_radius = 4;
						no_radius_when_single = 0;
						focused_opacity = 1.0;
						unfocused_opacity = 0.92;

						# Animations
						animations = 1;
						layer_animations = 1;
						animation_type_open = "fade";
						animation_type_close = "fade";
						layer_animation_type_open = "fade";
						layer_animation_type_close = "fade";
						animation_fade_in = 1;
						animation_fade_out = 1;
						tag_animation_direction = 0;
						zoom_initial_ratio = 0.3;
						zoom_end_ratio = 0.7;
						fadein_begin_opacity = 0.5;
						fadeout_begin_opacity = 0.8;
						animation_duration_move = 500;
						animation_duration_open = 400;
						animation_duration_tag = 350;
						animation_duration_close = 800;
						animation_duration_focus = 400;
						animation_curve_open = "0.46,1.0,0.29,1.1";
						animation_curve_move = "0.46,1.0,0.29,1";
						animation_curve_tag = "0.46,1.0,0.29,1";
						animation_curve_close = "0.08,0.92,0,1";
						animation_curve_focus = "0.46,1.0,0.29,1";

						xwayland_persistence = 1;
						syncobj_enable = 0;
						no_border_when_single = 0;
						axis_bind_apply_timeout = 100;
						focus_on_activate = 1;
						sloppyfocus = 1;
						warpcursor = 1;
						focus_cross_monitor = 0;
						focus_cross_tag = 0;
						circle_layout = "tile,scroller";
						enable_floating_snap = 1;
						snap_distance = 50;
						cursor_size = 24;
						cursor_theme = "Bibata-Modern-Ice";
						cursor_hide_timeout = 0;
						drag_tile_to_tile = 1;
						single_scratchpad = 1;

						layerrule = "animation_type_open:fade,animation_type_close:fade,layer_name:vicinae";
					};

					autostart_sh = "
						vicinae server &

						awww-daemon &

						awww img ${wallpaper}

						kitty &
					";
				};
			};
		};
	};
					   }
