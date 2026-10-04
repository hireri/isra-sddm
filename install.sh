#!/usr/bin/env bash
# one time install of the isra sddm theme

set -euo pipefail

SRC="$(dirname "$(readlink -f "$0")")"
DEST="${SDDM_THEME_DIR:-/usr/share/sddm/themes/isra}"
CONF="${SDDM_CONF_DIR:-/etc/sddm.conf.d}"
SUDO="${SUDO-sudo}"

for cmd in jq magick fc-match rsync; do
    command -v "$cmd" >/dev/null || { echo "[sddm-install] missing dependency: $cmd" >&2; exit 1; }
done

$SUDO install -d -o "$USER" -g "$(id -gn)" "$DEST"
cp -r "$SRC"/*.qml "$SRC"/*.js "$SRC"/sync.sh "$SRC"/qmldir "$SRC"/metadata.desktop "$DEST"/
rsync -a --exclude=.git --exclude=.gitignore --exclude=README.md --exclude=example\*.qml --exclude=ShapeCanvas.qml "$SRC"/shapes/ "$DEST"/shapes/

SDDM_THEME_DIR="$DEST" "$SRC/sync.sh"
[[ -s "$DEST/Generated.js" ]] || { echo "[sddm-install] sync produced no theme data (has the shell applied a wallpaper yet?); not activating" >&2; exit 1; }

$SUDO install -d "$CONF"
printf '[Theme]\nCurrent=isra\n' | $SUDO tee "$CONF/isra.conf" >/dev/null
echo "[sddm-install] installed to $DEST"
