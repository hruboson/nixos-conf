#!/usr/bin/env sh
cmd="$1"
find /nix/store -type f \( -name "$cmd.png" -o -name "$cmd.svg" \) 2>/dev/null
