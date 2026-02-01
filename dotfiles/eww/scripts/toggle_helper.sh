#!/usr/bin/env bash

# Get list of active windows with the name helper_window
active_windows=$(eww active-windows | awk -F: '/helper_window/ {print $1}')

if [ -n "$active_windows" ]; then
    # if any helper window is active, close it
    for win in $active_windows; do
        eww close "$win"
    done
else
	# open all defined windows here
	eww open helper_window
fi
