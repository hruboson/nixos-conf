#!/usr/bin/env bash
# krita-export.sh
#
# Copies the Krita files that the nix module installs from your LIVE Krita
# folders into ./config next to this script.
#
#   ./krita-export.sh                    export everything, all loose .kpp brushes
#   ./krita-export.sh "d)_Ink Pen.kpp"   export everything, but only these brushes
#
# Environment:
#   DEST            target folder (default: <script dir>/config)
#   BRUSH_DEST      brush folder  (default: <script dir>/brushes)
#   BUNDLE_DEST     bundle folder (default: DEST/bundles)
#   BUNDLES         "a.bundle b.bundle" export only these (default: all found)
#   BUNDLE_SKIP     bundles to leave out (default: the ones Krita ships);
#                   BUNDLE_SKIP="" skips nothing
#   XDG_CONFIG_HOME / XDG_DATA_HOME are respected, so a sandbox run works too:
#     HOME=/tmp/kh XDG_CONFIG_HOME=/tmp/kh/.config XDG_DATA_HOME=/tmp/kh/.local/share ./krita-export.sh
#
# Layout written:
#   DEST/          kritarc  kritadisplayrc  krita5.xmlgui  color-schemes/  workspaces/
#   DEST/bundles/  *.bundle
#   BRUSH_DEST/    *.kpp

set -euo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${DEST:-$SCRIPT_DIR/config}"
BRUSH_DEST="${BRUSH_DEST:-$(dirname "${DEST%/}")/brushes}"
BUNDLE_DEST="${BUNDLE_DEST:-${DEST%/}/bundles}"
if [[ "${DEST%/}" == "${BRUSH_DEST%/}" || "${BRUSH_DEST%/}" == "${BUNDLE_DEST%/}" ]]; then
  echo "error: DEST/BRUSH_DEST and BRUSH_DEST/BUNDLE_DEST must be different folders" >&2
  exit 1
fi
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

if pgrep -x '(krita|\.krita-wrapped)' >/dev/null 2>&1; then
  echo "warning: Krita is running. It writes its settings when it quits," >&2
  echo "         so quit it first for a complete export." >&2
fi

mkdir -p "$DEST" "$BRUSH_DEST" "$BUNDLE_DEST"
echo "Exporting settings to: $DEST"
echo "Exporting brushes to:  $BRUSH_DEST"
echo "Exporting bundles to:  $BUNDLE_DEST"

# copy_file <source> <path relative to base> [base, default DEST]
# `install` follows symlinks, so files that came from the nix store are copied
# as real, writable files.
copy_file() {
  local src=$1 rel=$2 base=${3:-$DEST}
  if [[ -f $src ]]; then
    install -Dm644 -- "$src" "$base/$rel"
    echo "  copied   $base/$rel"
  else
    echo "  missing  $src (skipped)"
  fi
}

# --- Settings ---------------------------------------------------------------
copy_file "$CFG/kritarc"        "kritarc"
copy_file "$CFG/kritadisplayrc" "kritadisplayrc"

# --- Toolbar layout ---------------------------------------------------------
# Krita 5 keeps it under kxmlgui5/krita/, Krita 6 directly in the krita folder.
toolbar=""
for candidate in "$DATA/kxmlgui5/krita/krita5.xmlgui" "$DATA/krita/krita5.xmlgui"; do
  if [[ -f $candidate ]]; then
    toolbar=$candidate
    break
  fi
done
if [[ -n $toolbar ]]; then
  echo "  toolbar  from $toolbar"
  copy_file "$toolbar" "krita5.xmlgui"
else
  echo "  missing  krita5.xmlgui (skipped)"
fi

# --- Themes and workspaces --------------------------------------------------
for f in "$DATA/krita/color-schemes/"*.colors; do
  copy_file "$f" "color-schemes/$(basename "$f")"
done
for f in "$DATA/krita/workspaces/"*.kws; do
  copy_file "$f" "workspaces/$(basename "$f")"
done

# --- Brush presets ----------------------------------------------------------
names=()
if (( $# > 0 )); then
  names=("$@")
else
  for f in "$DATA/krita/paintoppresets/"*.kpp; do
    names+=("$(basename "$f")")
  done
fi
if (( ${#names[@]} > 0 )); then
  for n in "${names[@]}"; do
    copy_file "$DATA/krita/paintoppresets/$n" "$n" "$BRUSH_DEST"
  done
fi

# --- Resource bundles -------------------------------------------------------
# Collects *.bundle from share/krita/bundles/ and share/krita/ (bundles/ wins
# if the same file name exists in both).
read -ra bundle_skip <<< "${BUNDLE_SKIP-Krita_3_Default_Resources.bundle Krita_4_Default_Resources.bundle RGBA_brushes.bundle Krita_Artists_SeExpr_examples.bundle}"
declare -A bundle_done=()
for dir in "$DATA/krita/bundles" "$DATA/krita"; do
  for f in "$dir/"*.bundle; do
    n=$(basename "$f")
    [[ -n ${bundle_done[$n]:-} ]] && continue
    bundle_done[$n]=1
    if [[ -n ${BUNDLES:-} && " $BUNDLES " != *" $n "* ]]; then
      continue
    fi
    if [[ " ${bundle_skip[*]:-} " == *" $n "* ]]; then
      echo "  skipping $n (in BUNDLE_SKIP)"
      continue
    fi
    copy_file "$f" "$n" "$BUNDLE_DEST"
  done
done

echo
echo "Done. Review the changes (kritarc contains some noise like recent files),"
echo "then 'git add' the exported files. Brushes are only installed if listed in"
echo "the nix module's \`brushes\` list; everything in config/bundles is installed."
