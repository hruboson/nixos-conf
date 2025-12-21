#!/usr/bin/env bash

killall -9 .waybar-wrapped

waybar -c ~/.config/waybar/winstyle/config -s ~/.config/waybar/winstyle/style.css &
#waybar &
