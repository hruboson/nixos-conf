#!/usr/bin/env bash
# cinema-mode: dim every monitor except one (for mangowm / wl-gammarelay-rs)
#
# usage:
#   cinema-mode on [OUTPUT]   → dim all outputs except OUTPUT (default: focused output)
#   cinema-mode off           → restore previous brightness on all outputs
#   cinema-mode toggle [OUTPUT]
#   cinema-mode status        → prints "on <output>" or "off"
#
# env:
#   CINEMA_PRIMARY   output to keep lit (e.g. DP-1), overrides focus detection
#   CINEMA_DIM       brightness for dimmed outputs, 0.0–1.0 (default 0.03; 0 = fully black)
#
# requires: wl-gammarelay-rs running, busctl, awk

DIM="${CINEMA_DIM:-0.13}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/cinema-mode"
STATE_FILE="$STATE_DIR/state"
SERVICE="rs.wl-gammarelay"
IFACE="rs.wl.gammarelay"

mkdir -p "$STATE_DIR"

# DP-1 -> DP_1 (dbus object path form used by wl-gammarelay-rs)
to_path() { echo "/outputs/${1//-/_}"; }

# list output names as wl-gammarelay-rs knows them (dbus form, e.g. DP_1)
list_outputs() {
	busctl --user tree "$SERVICE" 2>/dev/null \
		| grep -o '/outputs/[^ ]*' \
		| sed 's|/outputs/||'
}

get_brightness() {
	busctl --user get-property "$SERVICE" "/outputs/$1" "$IFACE" Brightness \
		| awk '{print $2}'
}

set_brightness() {
	busctl --user -- set-property "$SERVICE" "/outputs/$1" "$IFACE" Brightness d "$2"
}

# focused output according to mangowm's mmsg
# (expects lines like "DP-1 selmon 1" from `mmsg -g`)
focused_output() {
	command -v mmsg >/dev/null 2>&1 || return 1
	mmsg -g 2>/dev/null | awk '$2 == "selmon" && $3 == 1 {print $1; exit}'
}

resolve_primary() {
	local p="${1:-${CINEMA_PRIMARY:-}}"
	[ -z "$p" ] && p=$(focused_output)
	# fall back to the first output wl-gammarelay knows about
	[ -z "$p" ] && p=$(list_outputs | head -n1)
	echo "${p//-/_}"
}

is_on() { [ -f "$STATE_FILE" ]; }

cinema_on() {
	if is_on; then
		echo "cinema-mode already on (primary: $(sed -n 1p "$STATE_FILE"))" >&2
		exit 0
	fi

	local primary
	primary=$(resolve_primary "$1")

	if ! list_outputs | grep -qx "$primary"; then
		echo "Output '$primary' not found. Known outputs:" >&2
		list_outputs >&2
		exit 1
	fi

	# state file: line 1 = primary, following lines = "output brightness"
	echo "$primary" > "$STATE_FILE"
	for out in $(list_outputs); do
		echo "$out $(get_brightness "$out")" >> "$STATE_FILE"
		if [ "$out" != "$primary" ]; then
			set_brightness "$out" "$DIM"
		fi
	done
}

cinema_off() {
	if ! is_on; then
		# nothing saved: just make sure everything is at full brightness
		for out in $(list_outputs); do set_brightness "$out" 1; done
		exit 0
	fi

	tail -n +2 "$STATE_FILE" | while read -r out value; do
		set_brightness "$out" "${value:-1}"
	done
	rm -f "$STATE_FILE"
}

case "$1" in
	on)
		cinema_on "$2"
		;;
	off)
		cinema_off
		;;
	toggle)
		if is_on; then cinema_off; else cinema_on "$2"; fi
		;;
	status)
		if is_on; then echo "on $(sed -n 1p "$STATE_FILE")"; else echo "off"; fi
		;;
	*)
		echo "Usage: $0 {on [output]|off|toggle [output]|status}" >&2
		exit 1
		;;
esac
