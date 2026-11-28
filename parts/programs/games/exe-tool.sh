GAMES_DIR="${GAMES_DIR:-$HOME/Games}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
PREFIXES="$DATA/exe-tool/prefixes"
LOGDIR="${XDG_CACHE_HOME:-$HOME/.cache}/exe-tool"
LOCAL_PREFIX_NAME="exe-tool-prefix"
HEROIC_DIR="$HOME/.config/heroic"
HEROIC_LIB="$HEROIC_DIR/sideload_apps/library.json"
mkdir -p "$PREFIXES" "$LOGDIR" "$GAMES_DIR"

trap '' PIPE    # writing to a closed spinner window must not kill the script
BUSY_PID=""; BUSY_FD=""; BUSY_FIFO=""

# busy_start "text" [auto-close seconds]
busy_start() {
  busy_stop
  BUSY_FIFO="$(mktemp -u)"; mkfifo "$BUSY_FIFO"
  timeout "${2:-0}" zenity --progress --pulsate --auto-close --no-cancel \
    --title="Windows games" --text="$1" <"$BUSY_FIFO" >/dev/null 2>&1 &
  BUSY_PID=$!
  exec {BUSY_FD}>"$BUSY_FIFO"
}

busy_msg() {
  if [ -n "$BUSY_FD" ]; then
    { echo "# $1" >&"$BUSY_FD"; } 2>/dev/null || true
  fi
}

busy_stop() {
  if [ -n "$BUSY_FD" ]; then exec {BUSY_FD}>&-; fi
  if [ -n "$BUSY_PID" ]; then
    kill "$BUSY_PID" 2>/dev/null || true
    wait "$BUSY_PID" 2>/dev/null || true
  fi
  if [ -n "$BUSY_FIFO" ]; then rm -f "$BUSY_FIFO"; fi
  BUSY_PID=""; BUSY_FD=""; BUSY_FIFO=""
}
trap busy_stop EXIT

note() { notify-send -a "Windows games" -i wine "$1" "${2:-}" 2>/dev/null || echo "[exe-tool] $1 ${2:-}" >&2; }

# ---------- helpers ----------

# can this folder hold a Wine prefix? (writable + symlinks supported; fails on FAT/exFAT)
can_symlink() {
  local t ok=1
  t="$(mktemp -d -p "$1" .exe-tool-test.XXXXXX 2>/dev/null)" || return 1
  mkdir -p "$t/dosdevices"
  if ln -s ../drive_c "$t/dosdevices/c:" 2>/dev/null; then ok=0; fi
  rm -rf "$t"
  return "$ok"
}

# prefix implied by the exe's location: inside a prefix, or a portable prefix next to/above it
local_prefix_for() {
  local exe="$1" d
  case "$exe" in
	*/drive_c/*)
      d="${exe%%/drive_c/*}"; d="${d%/pfx}"; echo "$d"; return 0 ;;
  esac
  d="$(dirname "$exe")"
  for _ in 1 2 3 4 5; do
    if [ -d "$d/$LOCAL_PREFIX_NAME" ]; then echo "$d/$LOCAL_PREFIX_NAME"; return 0; fi
    if [ "$d" = "/" ]; then break; fi
    d="$(dirname "$d")"
  done
  return 0
}

# fallback prefix: ~/Games/<Name>/... gets its own, everything else shares "default"
prefix_for() {
  local exe="$1" rel name
  case "$exe" in
    "$GAMES_DIR"/*)
      rel="${exe#"$GAMES_DIR"/}"
      if [[ "$rel" == */* ]]; then name="${rel%%/*}"; else name="${rel%.*}"; fi ;;
    *) name="default" ;;
  esac
  echo "$PREFIXES/$name"
}

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

# prefix Heroic uses for this game (per-game setting first, then global default)
heroic_prefix_for() {
  local app="$1" hp cand
  for cand in \
    "$(jq -r --arg a "$app" '.[$a].winePrefix // empty' "$HEROIC_DIR/GamesConfig/$app.json" 2>/dev/null || true)" \
    "$(jq -r '.defaultSettings.winePrefix // empty' "$HEROIC_DIR/config.json" 2>/dev/null || true)"
  do
    hp="${cand/#\~/$HOME}"
    if [ -z "$hp" ] || [ ! -d "$hp" ]; then continue; fi
    if [ ! -d "$hp/drive_c" ] && [ -d "$hp/pfx/drive_c" ]; then hp="$hp/pfx"; fi
    echo "$hp"; return 0
  done
  return 0
}

setup_env() {
  local hit app hp pbin
  PREFIX="${EXE_TOOL_PREFIX:-}"
  if [ -z "$PREFIX" ]; then PREFIX="$(local_prefix_for "$1")"; fi

  # not inside/next to a local prefix: use Heroic's prefix + Proton if Heroic knows the game
  if [ -z "$PREFIX" ]; then
    hit="$(find_heroic_entry "$1")"
    if [ -n "$hit" ]; then
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
  fi

  if [ -z "$PREFIX" ]; then PREFIX="$(prefix_for "$1")"; fi

  mkdir -p "$PREFIX"
  export WINEPREFIX="$PREFIX"
  export GAMEID="${GAMEID:-umu-0}"
  export PROTONPATH="${PROTONPATH:-GE-Proton}"
  # shellcheck source=/dev/null
  if [ -f "$PREFIX/exe-tool.env" ]; then set -a; . "$PREFIX/exe-tool.env"; set +a; fi
}

# ---------- icons & shortcuts ----------

extract_icon() {
  local exe="$1" out="$2" tmp best
  tmp="$(mktemp -d)"
  wrestool -x --type=14 -o "$tmp" "$exe" 2>/dev/null || true
  icotool -x -o "$tmp" "$tmp"/*.ico 2>/dev/null || true
  best="$(find "$tmp" -name '*.png' -printf '%s %p\n' | sort -rn | head -n1 | cut -d' ' -f2- || true)"
  if [ -n "$best" ]; then cp "$best" "$out"; rm -rf "$tmp"; return 0; fi
  rm -rf "$tmp"; return 1
}

# nice name: "C:\Program Files\<Game>\x.exe" -> Game, otherwise the exe name
shortcut_name() {
  local exe="$1" rel
  case "$exe" in
    */drive_c/Program\ Files*/*/*)
      rel="${exe#*/drive_c/Program Files*/}"
      echo "${rel%%/*}" ;;
    *) basename "${exe%.*}" ;;
  esac
}

write_desktop() {   # file name exe icon
  cat > "$1" <<EOF
[Desktop Entry]
Type=Application
Name=$2
Exec=exe-tool run "$3"
Path=$(dirname "$3")
Icon=$4
Categories=Game;
Terminal=false
EOF
  chmod +x "$1"
}

# make_shortcut <exe> [dest_dir]
#   with dest_dir: only a shortcut in that folder
#   without:       app menu entry + desktop shortcut
make_shortcut() {
  local exe="$1" dest="${2:-}" name icon_dir icon desk
  name="$(shortcut_name "$exe")"
  icon_dir="$DATA/icons/exe-tool"; mkdir -p "$icon_dir"
  icon="$icon_dir/$name.png"
  if ! extract_icon "$exe" "$icon"; then icon="wine"; fi

  if [ -n "$dest" ]; then
    write_desktop "$dest/$name.desktop" "$name" "$exe" "$icon"
    note "Shortcut created" "$dest/$name.desktop"
    return 0
  fi

  mkdir -p "$DATA/applications"
  write_desktop "$DATA/applications/exe-tool-$name.desktop" "$name" "$exe" "$icon"
  desk="$(xdg-user-dir DESKTOP)"
  cp "$DATA/applications/exe-tool-$name.desktop" "$desk/$name.desktop"
  chmod +x "$desk/$name.desktop"
  note "Shortcut created" "$name (desktop + app menu)"
}

# ---------- portable prefix ----------

create_local_prefix() {
  local exe="$1" dir p src size choice need avail
  case "$exe" in
    */drive_c/*) note "Already inside a prefix" "Nothing to create"; return 0 ;;
  esac
  dir="$(dirname "$exe")"
  p="$dir/$LOCAL_PREFIX_NAME"
  if [ -d "$p" ]; then note "Portable prefix already exists" "$p"; return 0; fi
  if ! can_symlink "$dir"; then
    note "Can't create a prefix here" "Folder is read-only or the filesystem has no symlink support (FAT/exFAT)"
    return 1
  fi

  # which prefix would this exe use right now? (Heroic's, a central one, ...)
  src="$( setup_env "$exe" >/dev/null 2>&1; echo "$PREFIX" )"

  choice="empty"
  if [ -n "$src" ] && [ -d "$src/drive_c" ]; then
    size="$(du -sh "$src" 2>/dev/null | cut -f1)"
    choice="$(kdialog --title "Portable prefix" \
      --menu "Current prefix of this exe:\n$src\nSize: $size\n\nIf this prefix is shared with other games, their data will be copied too. Close the game before copying.\n\nCopy it into the new portable prefix?" \
      copy "Copy it (keeps saves and settings)" \
      empty "Start with an empty prefix" || true)"
    if [ -z "$choice" ]; then note "Cancelled" "No portable prefix created"; return 0; fi
  fi

  if [ "$choice" = "copy" ]; then
    need="$(du -sb "$src" 2>/dev/null | cut -f1)"
    avail="$(df --output=avail -B1 "$dir" | tail -n1 | tr -d ' ')"
    if [ -n "$need" ] && [ -n "$avail" ] && [ "$need" -gt "$avail" ]; then
      note "Not enough free space" "Need $size on the target drive"
      return 1
    fi
  fi

  mkdir -p "$p"
  if [ "$choice" = "copy" ]; then
    busy_start "Copying prefix ($size), please wait…"
    if ! cp -a --reflink=auto --no-preserve=ownership "$src/." "$p/"; then
      busy_stop; rm -rf "$p"
      note "Copy failed" "Partial portable prefix removed"
      return 1
    fi
    busy_stop
    note "Portable prefix created" "$p (copied from $src; the original is untouched)"
  else
    note "Portable prefix created" "$p (empty; used the next time you run this exe)"
  fi
}

# ---------- installers ----------

is_installer() {
  local exe="$1" name
  if [ -n "${EXE_TOOL_NO_INSTALLER:-}" ]; then return 1; fi
  case "$exe" in */drive_c/*) return 1 ;; esac
  name="${exe##*/}"; name="${name,,}"
  case "$name" in
    *.msi) return 0 ;;
    *.exe) ;;
    *) return 1 ;;
  esac
  case "$name" in
    unins*|*uninstall*) return 1 ;;
  esac
  if [ -n "$(find_heroic_entry "$exe")" ]; then return 1; fi
  case "$name" in
    *setup*|*install*) return 0 ;;
  esac
  # installer framework signatures near the start of the file
  grep -aqE 'Inno Setup|Nullsoft Install System|InstallShield|WixBundle' < <(head -c 4194304 "$exe")
}

new_local_prefix() {   # prints a fresh prefix path next to the installer
  local dir base p n=1
  dir="$(dirname "$1")"; base="$(basename "${1%.*}")"
  p="$dir/$base-prefix"
  while [ -e "$p" ]; do n=$((n + 1)); p="$dir/$base-prefix-$n"; done
  echo "$p"
}

list_exes() {
  local r="$1"
  [ -d "$r/pfx/drive_c" ] && r="$r/pfx"
  find "$r/drive_c" -path "$r/drive_c/windows" -prune -o -type f -iname '*.exe' -print 2>/dev/null | sort
}

run_installer() {
  local exe="$1"; shift
  local dir p log before after rc=0 pick f
  local -a new args
  dir="$(dirname "$exe")"
  log="$LOGDIR/installer-$(basename "${exe%.*}").log"

  p="$(new_local_prefix "$exe")"
  if ! can_symlink "$dir"; then
    p="$PREFIXES/$(basename "${exe%.*}")-$(date +%s)"
    note "Can't keep the prefix next to the installer" "No write/symlink support there; using $p"
  fi

  export EXE_TOOL_PREFIX="$p"
  setup_env "$exe"
  cd "$dir"
  note "Running installer" "$(basename "$exe")  [prefix: $PREFIX]"
  busy_start "Preparing a new Wine prefix…"
  umu-run wineboot -u >"$log" 2>&1 || true
  before="$(mktemp)"; list_exes "$PREFIX" > "$before"
  busy_stop

  if [ ! -d "$PREFIX/pfx/drive_c" ] && [ ! -d "$PREFIX/drive_c" ]; then
    note "Could not create the Wine prefix" "See $log"
    rm -rf "$p"
    return 1
  fi

  case "${exe,,}" in
    *.msi) umu-run msiexec /i "$exe" "$@" >>"$log" 2>&1 || rc=$? ;;
    *)     umu-run "$exe" "$@"            >>"$log" 2>&1 || rc=$? ;;
  esac
  umu-run wineserver -w >>"$log" 2>&1 || true   # wait for leftover installer processes

  if [ "$rc" -ne 0 ]; then note "Installer exited with code $rc" "Log: $log"; fi

  after="$(mktemp)"; list_exes "$PREFIX" > "$after"
  mapfile -t new < <(comm -13 "$before" "$after" \
    | grep -viE '(/(unins|uninstall|vc_?redist|dxsetup|dxwebsetup|dotnet|ue4prereq|oalinst)[^/]*\.exe$)|crash' || true)
  rm -f "$before" "$after"

  case "${#new[@]}" in
    0) note "Installer finished" "No new program found. Run the installed exe manually, it will use this prefix."
       return 0 ;;
    1) pick="${new[0]}" ;;
    *) args=()
       for f in "${new[@]}"; do args+=("$f" "${f#"$PREFIX"/drive_c/}"); done
       pick="$(kdialog --menu "Which program should the shortcut launch?" "${args[@]}" || true)" ;;
  esac

  if [ -z "$pick" ]; then note "No shortcut created" "No program selected"; return 0; fi
  if [ -w "$dir" ]; then make_shortcut "$pick" "$dir"; else make_shortcut "$pick"; fi
}

# ---------- running ----------

do_run() {
  local exe="$1"; shift
  if is_installer "$exe"; then run_installer "$exe" "$@"; return 0; fi

  setup_env "$exe"
  local log rc=0
  log="$LOGDIR/$(basename "$PREFIX").log"
  cd "$(dirname "$exe")"
  note "Launching" "$(basename "$exe")  [prefix: $PREFIX]"
  busy_start "Starting $(basename "$exe")…" 12
  case "${exe,,}" in
    *.msi) umu-run msiexec /i "$exe" "$@" >"$log" 2>&1 || rc=$? ;;
    *.bat) umu-run cmd /c "$exe" "$@"     >"$log" 2>&1 || rc=$? ;;
    *)     umu-run "$exe" "$@"            >"$log" 2>&1 || rc=$? ;;
  esac
  if [ "$rc" -ne 0 ]; then note "Exited with error ($rc)" "Log: $log"; fi
}

# ---------- heroic ----------

add_heroic() {
  local exe="$1" title id icon hit
  hit="$(find_heroic_entry "$exe")"
  if [ -n "$hit" ]; then
    note "Already in Heroic" "${hit#*$'\t'}"; return 0
  fi

  title="$(shortcut_name "$exe")"
  id="$(printf '%s' "$exe" | sha1sum | cut -c1-20)"
  mkdir -p "$(dirname "$HEROIC_LIB")"
  if [ ! -f "$HEROIC_LIB" ]; then echo '{"games":[]}' > "$HEROIC_LIB"; fi
  icon="$DATA/icons/exe-tool/$title.png"
  mkdir -p "$(dirname "$icon")"
  if [ ! -f "$icon" ]; then
    if ! extract_icon "$exe" "$icon"; then icon=""; fi
  fi
  if [ -n "$icon" ]; then icon="file://$icon"; fi

  jq --arg id "$id" --arg t "$title" --arg e "$exe" --arg d "$(dirname "$exe")" --arg i "$icon" \
    '.games += [{runner:"sideload", app_name:$id, title:$t,
                 install:{executable:$e, platform:"Windows", is_dlc:false},
                 folder_name:$d, art_cover:$i, art_square:$i,
                 is_installed:true, canRunOffline:true,
                 browserUrl:"", customUserAgent:"", launchFullScreen:false}]' \
    "$HEROIC_LIB" > "$HEROIC_LIB.tmp" && mv "$HEROIC_LIB.tmp" "$HEROIC_LIB"
  note "Added to Heroic" "$title: restart Heroic to see it"
}

# ---------- main ----------

cmd="${1:-}"
if [ $# -gt 0 ]; then shift; fi
case "$cmd" in
  run)         exe="$(realpath -- "$1")"; shift; do_run "$exe" "$@" ;;
  plain)       exe="$(realpath -- "$1")"; shift; EXE_TOOL_NO_INSTALLER=1; export EXE_TOOL_NO_INSTALLER; do_run "$exe" "$@" ;;
  install)     exe="$(realpath -- "$1")"; shift; run_installer "$exe" "$@" ;;
  mango)       exe="$(realpath -- "$1")"; export MANGOHUD=1; do_run "$exe" ;;
  localprefix) create_local_prefix "$(realpath -- "$1")" ;;
  shortcut)    make_shortcut "$(realpath -- "$1")" ;;
  heroic)      add_heroic "$(realpath -- "$1")" ;;
  winecfg)     setup_env "$(realpath -- "$1")"; umu-run winecfg ;;
  winetricks)
    setup_env "$(realpath -- "$1")"
    verbs="$(kdialog --inputbox "winetricks verbs (empty = GUI), e.g. vcrun2022 dotnet48" || true)"
    if [ -z "$verbs" ]; then umu-run winetricks --gui
    else busy_start "Running winetricks $verbs…"; umu-run winetricks $verbs; busy_stop; fi ;;
  prefix)      setup_env "$(realpath -- "$1")"; xdg-open "$PREFIX" ;;
  kill)        setup_env "$(realpath -- "$1")"; umu-run wineserver -k || true; note "Wine processes killed" ;;
  *) echo "usage: exe-tool {run|plain|install|mango|localprefix|shortcut|heroic|winecfg|winetricks|prefix|kill} file.exe" >&2; exit 1 ;;
esac
