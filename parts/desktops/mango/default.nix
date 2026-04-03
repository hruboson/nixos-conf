{ self, inputs, ... }: {
	flake.nixosModules.mango = { config, lib, pkgs, username, ... }: {
		imports = [ 
			inputs.mango.nixosModules.mango 
			inputs.silentSDDM.nixosModules.default

			#self.nixosModules.bar
		];

		options.desktops.mango = {
			monitors = lib.mkOption {
				type = lib.types.str;
				# no default = required, will error if not set
				description = "Mango monitor configuration";
			};
		};

		config = {
			programs.mango.enable = true;
			#environment.sessionVariables.NIXOS_OZONE_WL = "1";
			programs.dconf.enable = true;
			security.polkit.enable = true;
			services.dbus.enable = true;
			hardware.graphics.enable = true;
			#security.pam.services.hyprlock = {};

			xdg.portal.enable = true;
			xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

			programs.silentSDDM = {
				enable = false;
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

			services.greetd = {
				enable = true;
				settings = {
					default_session = {
						command = "mango";
						user = username;
					};
				};
			};

			environment.systemPackages = (with pkgs; [
				killall

				wev
				wayland
				wlr-randr
				wdisplays

				vicinae
				quickshell
				qt6.qtwayland

				grim	# Screenshot utility
				slurp # Select region for grim
				pwvucontrol	# volume and sound gui control
				pulseaudio # volume and sound control
			]);

			home-manager.users.${username} = {
				imports = [ inputs.mango.hmModules.mango ];
				wayland.windowManager.mango = {
					enable = true;
					settings = ''
						###############
						#	LAYOUTS	  #
						###############

						# Scroller Layout Setting
						scroller_structs=10
						scroller_default_proportion=0.40
						scroller_focus_center=1
						scroller_prefer_center=1
						edge_scroller_pointer_focus=1
						scroller_ignore_proportion_single=0
						scroller_default_proportion_single=1.0

						# Master-Stack Layout Setting
						new_is_master=0
						smartgaps=0
						default_mfact=0.55
						default_nmaster=1

						# Overview Setting
						hotarea_size=10
						enable_hotarea=1
						ov_tab_mode=0
						overviewgappi=5
						overviewgappo=30

						#############
						#	TAGS	#
						#############

						#... maybe move this as an option, similar to monitors

						# DESKTOP
						tagrule=id:1,monitor_name:DP-2,layout_name:deck
						tagrule=id:2,monitor_name:DP-2,layout_name:deck
						tagrule=id:3,monitor_name:DP-2,layout_name:deck
						tagrule=id:4,monitor_name:DP-2,layout_name:deck
						tagrule=id:5,monitor_name:DP-2,layout_name:deck
						tagrule=id:6,monitor_name:DP-2,layout_name:deck
						tagrule=id:7,monitor_name:DP-2,layout_name:deck
						tagrule=id:8,monitor_name:DP-2,layout_name:deck
						tagrule=id:9,monitor_name:DP-2,layout_name:deck

						tagrule=id:1,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:2,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:3,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:4,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:5,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:6,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:7,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:8,monitor_name:HDMI-A-1,layout_name:deck
						tagrule=id:9,monitor_name:HDMI-A-1,layout_name:deck

						tagrule=id:1,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:2,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:3,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:4,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:5,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:6,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:7,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:8,monitor_name:HDMI-A-2,layout_name:vertical_scroller
						tagrule=id:9,monitor_name:HDMI-A-2,layout_name:vertical_scroller

						#################
						#	KEYBOARD	#
						#################

						repeat_rate=25
						repeat_delay=600
						numlockon=1
						xkb_rules_layout=cz
						xkb_rules_options = grp:alt_shift_toggle
						# xkb_rules_options=ctrl:nocaps
						# xkb_rules_options=grp:alt_altgr_toggle,caps:hyper

						# Trackpad 
						disable_trackpad=0
						tap_to_click=1
						tap_and_drag=1
						drag_lock=false
						mouse_natural_scrolling=0
						trackpad_natural_scrolling=0
						disable_while_typing=1
						left_handed=0
						middle_button_emulation=0
						swipe_min_threshold=1
						accel_profile=2
						accel_speed=0.0
						# scroll_button=274
						# scroll_method=1

						#################
						#	KEYBINDS	#
						#################

						mousebind=SUPER,btn_left,moveresize,curmove
						mousebind=SUPER,btn_right,moveresize,curresize
						mousebind=SUPER+CTRL,btn_right,killclient

						bind=SUPER,r,reload_config
						bind=SUPER,Return,spawn,kitty
						bind=SUPER,space,spawn,vicinae toggle
						bind=SUPER,v,spawn,vicinae vicinae://extensions/vicinae/clipboard/history

						# vertical_scroller
						bind=SUPER,Up,focusdir,up
						bind=SUPER,Down,focusdir,down
						bind=SUPER,equal,set_proportion,+0.1
						bind=SUPER,minus,set_proportion,-0.1
						axisbind=SUPER,UP,focusdir,up
						axisbind=SUPER,DOWN,focusdir,down

						# windows
						bind=SUPER,Right,focusstack,next
						bind=SUPER,Left,focusstack,prev
						bind=SUPER+SHIFT,Up,exchange_client,up
						bind=SUPER+SHIFT,Down,exchange_client,down
						bind=SUPER+SHIFT,Left,exchange_client,left
						bind=SUPER+SHIFT,Right,exchange_client,right

						bind=SUPER+SHIFT,q,killclient

						# monitor nav
						bind=SUPER+CTRL,Left,focusmon,left
						bind=SUPER+CTRL,Right,focusmon,right

						# tag nav
						bind=SUPER,1,view,1,0
						bind=SUPER,2,view,2,0
						bind=SUPER,3,view,3,0
						bind=SUPER,4,view,4,0
						bind=SUPER,5,view,5,0
						bind=SUPER,6,view,6,0
						bind=SUPER,7,view,7,0
						bind=SUPER,8,view,8,0
						bind=SUPER,9,view,9,0
						bind=SUPER+SHIFT,1,toggleview,1
						bind=SUPER+SHIFT,2,toggleview,2
						bind=SUPER+SHIFT,3,toggleview,3
						bind=SUPER+SHIFT,4,toggleview,4
						bind=SUPER+SHIFT,5,toggleview,5
						bind=SUPER+SHIFT,6,toggleview,6
						bind=SUPER+SHIFT,7,toggleview,7
						bind=SUPER+SHIFT,8,toggleview,8
						bind=SUPER+SHIFT,9,toggleview,9

						#################
						#	APPEARANCE	#
						#################

						gappih=5
						gappiv=5
						gappoh=5
						gappov=5
						scratchpad_width_ratio=0.8
						scratchpad_height_ratio=0.9
						borderpx=0
						rootcolor=0x201b14ff
						bordercolor=0x444444ff
						focuscolor=0x8BAA9Bff
						maximizescreencolor=0xBABD2Cff
						urgentcolor=0xad401fff
						scratchpadcolor=0xc4939dff
						globalcolor=0x8d64cfff
						overlaycolor=0x95C381ff

						# Effect
						blur=0
						blur_layer=1
						blur_optimized=1
						blur_params_num_passes = 2
						blur_params_radius = 5
						blur_params_noise = 0.02
						blur_params_brightness = 0.9
						blur_params_contrast = 0.9
						blur_params_saturation = 1.2

						shadows = 1
						layer_shadows = 1
						shadow_only_floating=1
						shadows_size = 12
						shadows_blur = 15
						shadows_position_x = 0
						shadows_position_y = 0
						shadowscolor= 0x000000ff

						border_radius=4
						no_radius_when_single=0
						focused_opacity=1.0
						unfocused_opacity=0.92

						# Animation Configuration
						animations=1
						layer_animations=1
						animation_type_open=fade
						animation_type_close=fade
						layer_animation_type_open=fade
						layer_animation_type_close=fade 
						animation_fade_in=1
						animation_fade_out=1
						tag_animation_direction=0
						zoom_initial_ratio=0.3
						zoom_end_ratio=0.7
						fadein_begin_opacity=0.5
						fadeout_begin_opacity=0.8
						animation_duration_move=500
						animation_duration_open=400
						animation_duration_tag=350
						animation_duration_close=800
						animation_duration_focus=400
						animation_curve_open=0.46,1.0,0.29,1.1
						animation_curve_move=0.46,1.0,0.29,1
						animation_curve_tag=0.46,1.0,0.29,1
						animation_curve_close=0.08,0.92,0,1
						animation_curve_focus=0.46,1.0,0.29,1

						#################
						#	MONITORS	#
						#################

						${config.desktops.mango.monitors}

						#############
						#	MISC	#
						#############

						xwayland_persistence=1
						syncobj_enable=0
						no_border_when_single=0
						axis_bind_apply_timeout=100
						focus_on_activate=1
						inhibit_regardless_of_visibility=0
						sloppyfocus=1
						warpcursor=1
						focus_cross_monitor=0
						focus_cross_tag=0
						circle_layout=tile,scroller
						enable_floating_snap=1
						snap_distance=50
						cursor_size=24
						cursor_theme=Bibata-Modern-Ice
						cursor_hide_timeout=0
						drag_tile_to_tile=1
						single_scratchpad = 1
						
						# Execute autostart.sh defined in autostart_sh
						#exec-once=~/.config/mango/autostart.sh
						exec-once=vicinae server

						#############
						#	APPS	#
						#############

						# vicinae animation
						layerrule=animation_type_open:fade,animation_type_close:fade,layer_name:vicinae
					'';
					autostart_sh = ''
					'';
				};
			};
		};
	};
}
