#!/usr/bin/env bash

if eww active-windows | grep -q "portals_window_left" ; then
	eww update rev=false
	eww close portals_window_left
	eww close portals_window_right
else
	eww open portals_window_left
	eww open portals_window_right
	eww update rev=true
fi
