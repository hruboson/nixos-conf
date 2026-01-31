#!/usr/bin/env bash

# Path to shader
SHADER="$HOME/.config/hypr/shaders/grayscale.glsl"

# Check active shader
if hyprshade current | grep -q "grayscale"; then
    # Deactivate and reload
    hyprshade off
    hyprctl reload
	#hyprsunset --gamma 100 --gamma_max 100
else
    # ACTIVATES
    hyprshade on "$SHADER"
	#hyprsunset --gamma 200 --gamma_max 200

    # Force E-ink visuals: No animations, no shadows, thin black borders
    hyprctl keyword animations:enabled 0
    # hyprctl keyword decoration:drop_shadow 0
    # hyprctl keyword decoration:blur:enabled 0
    hyprctl keyword decoration:rounding 0
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:border_size 2
    hyprctl keyword general:col.active_border "rgba(000000ff)"
    hyprctl keyword general:col.inactive_border "rgba(000000ff)"
    hyprctl keyword decoration:dim_inactive 0
    
fi
