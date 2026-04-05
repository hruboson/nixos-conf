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
      ]);

      home-manager.users.${username} = {
        imports = [ inputs.mango.hmModules.mango ];
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
              "SUPER+SHIFT,1,toggleview,1"
              "SUPER+SHIFT,2,toggleview,2"
              "SUPER+SHIFT,3,toggleview,3"
              "SUPER+SHIFT,4,toggleview,4"
              "SUPER+SHIFT,5,toggleview,5"
              "SUPER+SHIFT,6,toggleview,6"
              "SUPER+SHIFT,7,toggleview,7"
              "SUPER+SHIFT,8,toggleview,8"
              "SUPER+SHIFT,9,toggleview,9"
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

            #"exec-once" = "vicinae server";

            layerrule = "animation_type_open:fade,animation_type_close:fade,layer_name:vicinae";
          };

          autostart_sh = "
			vicinae server
		  ";
        };
      };
    };
  };
}
