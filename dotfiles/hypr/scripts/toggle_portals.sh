#!/usr/bin/env bash

CURRENT=$(hyprctl activeworkspace -j | awk -F'"' '/"name":/ {print $4}')
WORKSPACE_NUMBER=100

if [ "$CURRENT" = "$WORKSPACE_NUMBER" ]; then
	~/.config/eww/scripts/toggle_portals.sh
	hyprctl dispatch workspace previous
else
	hyprctl dispatch workspace $WORKSPACE_NUMBER
	sleep 0.2
	~/.config/eww/scripts/toggle_portals.sh
fi
