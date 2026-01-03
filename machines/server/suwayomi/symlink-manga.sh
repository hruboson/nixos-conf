#!/run/current-system/sw/bin/bash
set -e

LOCAL_DIR="/var/lib/suwayomi-server/"
SOURCES=("/mnt/JARK/Manga") #"/mnt/CUTUP/Manga")

mkdir -p "$LOCAL_DIR"

# clear old symlinks
find "$LOCAL_DIR" -maxdepth 1 -type l -exec rm {} \;

for src in "${SOURCES[@]}"; do
	for manga in "$src"/*; do
		mangaName=$(basename "$manga")
		[[ "$mangaName" == "Zornhwa" ]] && continue
		ln -sfn "$manga" "$LOCAL_DIR/$mangaName"
	done
done
