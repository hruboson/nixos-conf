#!/usr/bin/env bash

MONITOR="HDMI-A-2"
LANDSCAPE_SINK="alsa_output.pci-0000_10_00.6.analog-stereo"
STATE_FILE="$XDG_RUNTIME_DIR/last_audio_sink"

# Add logging for debugging (optional)
LOG_FILE="/tmp/hyprland-monitor-switch.log"
echo "$(date): Starting monitor switch" >> "$LOG_FILE"

# Function to get current transform with retry
get_current_transform() {
    local retries=3
    local count=0
    local transform=""
    
    while [ $count -lt $retries ]; do
        transform=$(hyprctl monitors | awk -v m="$MONITOR" '
            $1=="Monitor" && $2==m {found=1; next}
            found && /transform/ {print $2; exit}
        ')
        
        if [ -n "$transform" ]; then
            echo "$transform"
            return 0
        fi
        
        count=$((count + 1))
        sleep 0.1
    done
    
    echo "0" # Default to landscape if can't detect
    return 1
}

switch_sink() {
    local sink="$1"
    
    # Check if sink exists
    if ! pactl list short sinks | grep -q "$sink"; then
        echo "$(date): Sink $sink not found" >> "$LOG_FILE"
        return 1
    fi
    
    # Set default sink
    if ! pactl set-default-sink "$sink"; then
        echo "$(date): Failed to set default sink" >> "$LOG_FILE"
        return 1
    fi
    
    # Move existing streams
    pactl list short sink-inputs | while read -r id _; do
        if ! pactl move-sink-input "$id" "$sink" 2>/dev/null; then
            echo "$(date): Failed to move sink input $id" >> "$LOG_FILE"
        fi
    done
    
    echo "$(date): Switched to sink $sink" >> "$LOG_FILE"
    return 0
}

get_current_sink() {
    pactl info | awk -F': ' '/Default Sink/ {print $2}'
}

# Get current transform
current=$(get_current_transform)
echo "$(date): Current transform: $current" >> "$LOG_FILE"

# Disable monitor first (with a small delay to ensure it's processed)
if ! wlr-randr --output "$MONITOR" --off 2>/dev/null; then
    echo "$(date): Failed to turn off monitor with wlr-randr" >> "$LOG_FILE"
    # Try alternative method
    hyprctl keyword monitor "$MONITOR,disable" >> "$LOG_FILE" 2>&1
fi

# Small delay to let changes settle
sleep 0.5

if [ "$current" = "1" ]; then
    echo "$(date): Switching from portrait to landscape" >> "$LOG_FILE"
    
    # ── Portrait → Landscape ─────────────────────────
    # Save current audio output
    current_sink=$(get_current_sink)
    if [ -n "$current_sink" ]; then
        echo "$current_sink" > "$STATE_FILE"
        echo "$(date): Saved sink: $current_sink" >> "$LOG_FILE"
    fi
    
    # Switch to speakers
    if ! switch_sink "$LANDSCAPE_SINK"; then
        echo "$(date): Failed to switch to landscape sink" >> "$LOG_FILE"
    fi
    
    # Apply monitor configuration
    if ! hyprctl keyword monitor "$MONITOR,2560x1440@59.95,0x1519,1.0,bitdepth,10,transform,0"; then
        echo "$(date): Failed to set monitor configuration" >> "$LOG_FILE"
        exit 1
    fi
    
else
    echo "$(date): Switching from landscape to portrait" >> "$LOG_FILE"
    
    # ── Landscape → Portrait ─────────────────────────
    # Switch audio output back to previous
    if [ -f "$STATE_FILE" ]; then
        PREV_SINK=$(cat "$STATE_FILE")
        if [ -n "$PREV_SINK" ] && [ "$PREV_SINK" != "$LANDSCAPE_SINK" ]; then
            if ! switch_sink "$PREV_SINK"; then
                echo "$(date): Failed to switch back to previous sink" >> "$LOG_FILE"
            fi
        fi
        rm -f "$STATE_FILE"
    fi
    
    # Apply monitor configuration
    if ! hyprctl keyword monitor "$MONITOR,2560x1440@59.95,1120x1519,1.0,bitdepth,10,transform,1"; then
        echo "$(date): Failed to set monitor configuration" >> "$LOG_FILE"
        exit 1
    fi
fi

# Small delay before turning monitor back on
sleep 0.5

# Turn monitor back on
if ! wlr-randr --output "$MONITOR" --on 2>/dev/null; then
    echo "$(date): Failed to turn on monitor with wlr-randr" >> "$LOG_FILE"
    # Force a monitor refresh
    hyprctl dispatch movewindow tomonitor "$MONITOR" >> "$LOG_FILE" 2>&1
fi

echo "$(date): Monitor switch completed" >> "$LOG_FILE"
