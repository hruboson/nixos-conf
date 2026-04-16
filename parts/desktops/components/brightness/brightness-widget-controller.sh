#!/usr/bin/env bash
# usage:
#   brightness-widget-controller get     → prints current brightness 0-100
#   brightness-widget-controller set 75  → sets brightness to 75%

# uses brightnessctl if screen supports it and wl-gammarelay if not
# 	brightnessctl set 20%
#   busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 0.5

# check if brightnessctl has any backlight devices
has_brightnessctl() {
	for device in /sys/class/backlight/*; do
		if [ -d "$device" ]; then
			return 0
		fi
	done
	return 1
}

case "$1" in
	get)
		if has_brightnessctl; then
			current=$(brightnessctl get)
			max=$(brightnessctl max)
			echo $((current * 100 / max))
		else
			busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Brightness | awk '{print int($2 * 100)}'
		fi
		;;
	set)
		if has_brightnessctl; then
			brightnessctl set "$2%"
		else
			value=$(awk "BEGIN {printf \"%.2f\", $2 / 100}")
			busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d "$value"
		fi
		;;
	get-temp)
		busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature \
			| awk '{print $2}'
		;;
	set-temp)
		# map 0–100 → 3000K–6500K
		temp=$(awk "BEGIN {printf \"%d\", 3000 + ($2/100)*(6500-3000)}")
		busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q "$temp"
		;;
	*)
		echo "Usage: $0 {get|set <value>}" >&2
		exit 1
		;;
esac
