GAMES_DIR="${GAMES_DIR:-$HOME/Games}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
PREFIXES="$DATA/exe-tool/prefixes"
LOGDIR="${XDG_CACHE_HOME:-$HOME/.cache}/exe-tool"
mkdir -p "$PREFIXES" "$LOGDIR" "$GAMES_DIR"

note() { notify-send -a "Windows games" -i wine "$1" "${2:-}" 2>/dev/null || echo "[exe-tool] $1 ${2:-}" >&2; }

prefix_for() {
  local exe="$1" rel name
  case "$exe" in
    "$PREFIXES"/*)
      rel="${exe#"$PREFIXES"/}"; echo "$PREFIXES/${rel%%/*}"; return ;;
    "$GAMES_DIR"/*)
      rel="${exe#"$GAMES_DIR"/}"
      if [[ "$rel" == */* ]]; then name="${rel%%/*}"; else name="${rel%.*}"; fi ;;
    *) name="default" ;;
  esac
  echo "$PREFIXES/$name"
}

# prints the prefix Heroic uses for this game (per-game setting first, then global default)
heroic_prefix_for() {
  local app="$1" hp cand
  for cand in \
    "$(jq -r --arg a "$app" '.[$a].winePrefix // empty' \
         "$HEROIC_DIR/GamesConfig/$app.json" 2>/dev/null || true)" \
    "$(jq -r '.defaultSettings.winePrefix // empty' \
         "$HEROIC_DIR/config.json" 2>/dev/null || true)"
  do
    hp="${cand/#\~/$HOME}"
    [ -n "$hp" ] && [ -d "$hp" ] || continue
    # Proton-style layout: the real prefix is the pfx/ subfolder
    if [ ! -d "$hp/drive_c" ] && [ -d "$hp/pfx/drive_c" ]; then hp="$hp/pfx"; fi
    echo "$hp"; return 0
  done
  return 0
}

setup_env() {
  local hit app hp pbin
  PREFIX="$(prefix_for "$1")"
  if [ -n "${EXE_TOOL_PREFIX:-}" ]; then PREFIX="$EXE_TOOL_PREFIX"; fi

  # if Heroic knows this game, use the prefix and Proton Heroic uses for it
  hit="$(find_heroic_entry "$1")"
  if [ -n "$hit" ] && [ -z "${EXE_TOOL_PREFIX:-}" ]; then
    app="${hit%%$'\t'*}"
    hp="$(heroic_prefix_for "$app")"
    if [ -n "$hp" ]; then
      PREFIX="$hp"
      pbin="$(jq -r --arg a "$app" '(.[$a].wineVersion // empty) // empty | select(.type=="proton") | .bin' \
              "$HEROIC_DIR/GamesConfig/$app.json" 2>/dev/null || true)"
      if [ -z "$pbin" ]; then
        pbin="$(jq -r '.defaultSettings.wineVersion | select(.type=="proton") | .bin // empty' \
                "$HEROIC_DIR/config.json" 2>/dev/null || true)"
      fi
      if [ -n "$pbin" ] && [ -x "$pbin" ]; then
        export PROTONPATH="${PROTONPATH:-$(dirname "$pbin")}"
      fi
    fi
  fi

  mkdir -p "$PREFIX"
  export WINEPREFIX="$PREFIX"
  export GAMEID="${GAMEID:-umu-0}"
  export PROTONPATH="${PROTONPATH:-GE-Proton}"
  # shellcheck source=/dev/null
  if [ -f "$PREFIX/exe-tool.env" ]; then set -a; . "$PREFIX/exe-tool.env"; set +a; fi
}

do_run() {
  local exe="$1"; shift
  setup_env "$exe"
  local log rc=0
  log="$LOGDIR/$(basename "$PREFIX").log"
  cd "$(dirname "$exe")"
  note "Launching" "$(basename "$exe")  [prefix: $PREFIX]"
  case "${exe,,}" in
    *.msi) umu-run msiexec /i "$exe" "$@" >"$log" 2>&1 || rc=$? ;;
    *.bat) umu-run cmd /c "$exe" "$@"     >"$log" 2>&1 || rc=$? ;;
    *)     umu-run "$exe" "$@"            >"$log" 2>&1 || rc=$? ;;
  esac
  if [ "$rc" -ne 0 ]; then note "Exited with error ($rc)" "Log: $log"; fi
}

extract_icon() {
  local exe="$1" out="$2" tmp best
  tmp="$(mktemp -d)"
  wrestool -x --type=14 -o "$tmp" "$exe" 2>/dev/null || true
  icotool -x -o "$tmp" "$tmp"/*.ico 2>/dev/null || true
  best="$(find "$tmp" -name '*.png' -printf '%s %p\n' | sort -rn | head -n1 | cut -d' ' -f2- || true)"
  if [ -n "$best" ]; then cp "$best" "$out"; rm -rf "$tmp"; return 0; fi
  rm -rf "$tmp"; return 1
}

make_shortcut() {
  local exe="$1" name icon_dir icon app desk
  name="$(basename "${exe%.*}")"
  icon_dir="$DATA/icons/exe-tool"; mkdir -p "$icon_dir"
  icon="$icon_dir/$name.png"
  extract_icon "$exe" "$icon" || icon="wine"
  app="$DATA/applications/exe-tool-$name.desktop"
  cat > "$app" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=exe-tool run "$exe"
Path=$(dirname "$exe")
Icon=$icon
Categories=Game;
Terminal=false
EOF
  chmod +x "$app"
  desk="$(xdg-user-dir DESKTOP)"
  cp "$app" "$desk/$name.desktop"; chmod +x "$desk/$name.desktop"
  note "Shortcut created" "$name (desktop + app menu)"
}

HEROIC_DIR="$HOME/.config/heroic"
HEROIC_LIB="$HEROIC_DIR/sideload_apps/library.json"

# prints "app_name<TAB>title" of the best matching Heroic entry, or nothing
find_heroic_entry() {
  local exe="$1" dir base parent
  [ -f "$HEROIC_LIB" ] || return 0
  dir="$(dirname "$exe")"
  base="$(basename "${exe%.*}")"
  parent="$(basename "$dir")"
  jq -r --arg exe "$exe" --arg base "$base" --arg parent "$parent" '
    def norm: ascii_downcase | gsub("[^a-z0-9]"; "");
    [ .games[] | . as $g
      | (if ($g.install.executable // "") == $exe then 3
         elif ($g.folder_name // "") != "" and ($exe | startswith($g.folder_name + "/")) then 2
         elif ($g.title | norm) == ($base | norm) or ($g.title | norm) == ($parent | norm) then 1
         else 0 end) as $s
      | select($s > 0)
      | {s: $s, a: $g.app_name, t: $g.title}
    ] | sort_by(-.s) | first // empty | "\(.a)\t\(.t)"
  ' "$HEROIC_LIB"
}

add_heroic() {
  local exe="$1" title id icon hit
  hit="$(find_heroic_entry "$exe")"
  if [ -n "$hit" ]; then
    note "Already in Heroic" "${hit#*$'\t'}"; return
  fi

  title="$(basename "${exe%.*}")"
  id="$(printf '%s' "$exe" | sha1sum | cut -c1-20)"
  mkdir -p "$(dirname "$HEROIC_LIB")"
  [ -f "$HEROIC_LIB" ] || echo '{"games":[]}' > "$HEROIC_LIB"
  icon="$DATA/icons/exe-tool/$title.png"
  mkdir -p "$(dirname "$icon")"
  [ -f "$icon" ] || extract_icon "$exe" "$icon" || icon=""
  [ -n "$icon" ] && icon="file://$icon"

  jq --arg id "$id" --arg t "$title" --arg e "$exe" --arg d "$(dirname "$exe")" --arg i "$icon" \
    '.games += [{runner:"sideload", app_name:$id, title:$t,
                 install:{executable:$e, platform:"Windows", is_dlc:false},
                 folder_name:$d, art_cover:$i, art_square:$i,
                 is_installed:true, canRunOffline:true,
                 browserUrl:"", customUserAgent:"", launchFullScreen:false}]' \
    "$HEROIC_LIB" > "$HEROIC_LIB.tmp" && mv "$HEROIC_LIB.tmp" "$HEROIC_LIB"
  note "Added to Heroic" "$title: restart Heroic to see it"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  run)      exe="$(realpath -- "$1")"; shift; do_run "$exe" "$@" ;;
  mango)    exe="$(realpath -- "$1")"; export MANGOHUD=1; do_run "$exe" ;;
  shortcut) make_shortcut "$(realpath -- "$1")" ;;
  heroic)   add_heroic "$(realpath -- "$1")" ;;
  winecfg)  setup_env "$(realpath -- "$1")"; umu-run winecfg ;;
  winetricks)
    setup_env "$(realpath -- "$1")"
    verbs="$(kdialog --inputbox "winetricks verbs (empty = GUI), e.g. vcrun2022 dotnet48" || true)"
    if [ -z "$verbs" ]; then umu-run winetricks --gui; else umu-run winetricks $verbs; fi ;;
  prefix)   setup_env "$(realpath -- "$1")"; xdg-open "$PREFIX" ;;
  kill)     setup_env "$(realpath -- "$1")"; umu-run wineserver -k || true; note "Wine processes killed" ;;
  *) echo "usage: exe-tool {run|mango|shortcut|heroic|winecfg|winetricks|prefix|kill} file.exe" >&2; exit 1 ;;
esac
