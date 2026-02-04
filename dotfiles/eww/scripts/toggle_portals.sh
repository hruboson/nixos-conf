#!/usr/bin/env bash

# Get list of active windows that start with "portals_window"
active_portals=$(eww active-windows | awk -F: '/portals_window|portals_closer/ {print $1}')

if [ -n "$active_portals" ]; then
    # if any portals_window is active, close them all
    eww update rev=false
    for win in $active_portals; do
        eww close "$win"
    done
else
	# open underlay for mouse events to close portals
    eww open portals_closer

	# open all defined windows here
	eww open portals_window_dev
	eww open portals_window_office
	eww open portals_window_img_video_audio
	eww open portals_window_utils
	eww open portals_window_browsers
	eww open portals_window_comms

	eww update rev=true
fi
