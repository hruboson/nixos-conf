#!/usr/bin/env bash

MONITOR="HDMI-A-2"

current=$(hyprctl monitors | awk -v m="$MONITOR" '
$1=="Monitor" && $2==m {found=1}
found && /transform/ {print $2; exit}
')

# wlr-randr forces hyprland to update output
wlr-randr --output $MONITOR --off

if [ "$current" = "1" ]; then
	# ── Portrait → Landscape ─────────────────────────
    hyprctl keyword monitor "$MONITOR,2560x1440@59.95,0x1519,1.0,bitdepth,10,transform,0"
else
	 # ── Landscape → Portrait ─────────────────────────
    hyprctl keyword monitor "$MONITOR,2560x1440@59.95,1120x1519,1.0,bitdepth,10,transform,1"
fi

wlr-randr --output $MONITOR --on
