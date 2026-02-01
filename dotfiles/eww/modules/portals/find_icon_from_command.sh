#!/usr/bin/env sh

# Currently not used
# The search takes way too long and also doesn't find everything
# TODO: find out how to efficiently find icons of programs (most likely from xdg desktop entries)

cmd="$1"
find /nix/store -type f \( -name "$cmd.png" -o -name "$cmd.svg" \) 2>/dev/null
