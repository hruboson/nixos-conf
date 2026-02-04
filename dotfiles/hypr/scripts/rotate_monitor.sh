#!/usr/bin/env bash

MONITOR="HDMI-A-2"

current=$(hyprctl monitors | awk -v m="$MONITOR" '
$1=="Monitor" && $2==m {found=1}
found && /transform/ {print $2; exit}
')

# Audio sinks
LANDSCAPE_SINK="alsa_output.pci-0000_10_00.6.analog-stereo"

# Where we remember the previous sink
STATE_FILE="$XDG_RUNTIME_DIR/last_audio_sink"

switch_sink() {
    local sink="$1"
    pactl set-default-sink "$sink"
    pactl list short sink-inputs | while read -r id _; do
        pactl move-sink-input "$id" "$sink"
    done
}

get_current_sink() {
    pactl info | awk -F': ' '/Default Sink/ {print $2}'
}

# wlr-randr forces hyprland to update output
wlr-randr --output $MONITOR --off

if [ "$current" = "1" ]; then
	# ── Portrait → Landscape ─────────────────────────
	get_current_sink > "$STATE_FILE" # save current audio output
	switch_sink "$LANDSCAPE_SINK" # switch to speakers
	
    hyprctl keyword monitor "$MONITOR,2560x1440@59.95,0x1519,1.0,bitdepth,10,transform,0"
else
	 # ── Landscape → Portrait ─────────────────────────
	if [ -f "$STATE_FILE" ]; then # switch audio output
		PREV_SINK=$(cat "$STATE_FILE")
		switch_sink "$PREV_SINK"
		rm -f "$STATE_FILE"
	fi

    hyprctl keyword monitor "$MONITOR,2560x1440@59.95,1120x1519,1.0,bitdepth,10,transform,1"
fi

wlr-randr --output $MONITOR --on
