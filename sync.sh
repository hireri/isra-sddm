#!/usr/bin/env bash
# push the shell's colors, config and wallpaper into the installed SDDM theme 

set -euo pipefail
umask 022

DIR="${SDDM_THEME_DIR:-/usr/share/sddm/themes/isra}"
SHELL_DIR="${ISRA_SHELL_DIR:-$HOME/.config/quickshell/isra}"
CONFIG="$HOME/.config/israshell/config.json"
COLORS="$HOME/.local/state/quickshell/generated/colors.json"
WALL="$HOME/.config/hypr/current_wall_prev"

if [[ ! -w "$DIR" ]]; then
    echo "[sddm-sync] $DIR is not writable (run install.sh once); skipping" >&2
    exit 0
fi
[[ -f "$CONFIG" && -f "$COLORS" ]] || { echo "[sddm-sync] missing config or colors; skipping" >&2; exit 0; }

if [[ -e "$WALL" ]]; then
    src="$(readlink -f "$WALL")"
    key="$src $(stat -c %Y "$src")"
    if [[ ! -s "$DIR/wall.jpg" || "$(cat "$DIR/wall.key" 2>/dev/null)" != "$key" ]]; then
        magick "${src}[0]" -resize '3840x>' -quality 90 "$DIR/wall.tmp.jpg" && mv -f "$DIR/wall.tmp.jpg" "$DIR/wall.jpg"
        printf '%s' "$key" > "$DIR/wall.key"
    fi
fi

if [[ -f "$HOME/.face" ]]; then { cp -f "$HOME/.face" "$DIR/face.png"; chmod 644 "$DIR/face.png"; }; else rm -f "$DIR/face.png"; fi

mkdir -p "$DIR/fonts"
fonts=()
while IFS= read -r fam; do
    [[ -n "$fam" ]] || continue
    IFS='|' read -r file got < <(fc-match -f '%{file}|%{family}\n' "$fam")
    [[ "${got,,}" == *"${fam,,}"* ]] || continue
    cp -u "$file" "$DIR/fonts/"
    fonts+=("fonts/$(basename "$file")")
done < <(jq -r '[.fontFamily, .clock.fontFamily] | unique[] // empty' "$CONFIG")

lang="$(jq -r '.language // "en_US"' "$CONFIG")"
overlay=/dev/null
for f in "$HOME/.config/israshell/i18n/$lang.json" "$SHELL_DIR/i18n/locales/$lang.json"; do
    [[ "$lang" != en_US && -f "$f" ]] && { overlay="$f"; break; }
done

jq -rn --arg user "$USER" \
    --slurpfile cfg "$CONFIG" --slurpfile col "$COLORS" \
    --slurpfile en "$SHELL_DIR/i18n/locales/en_US.json" --slurpfile ov "$overlay" \
    --argjson fonts "$(printf '%s\n' "${fonts[@]}" | jq -R . | jq -sc 'map(select(. != ""))')" '
    def pick: with_entries(select(.key | test("^(lockSurface|logout|clock)\\.")));
    ".pragma library\n"
    + "const user = \($user | tojson);\n"
    + "const fonts = \($fonts | tojson);\n"
    + "const colors = \($col[0] | {md3} | tojson);\n"
    + "const config = \($cfg[0] | {lockscreen, clock, desktopClock, screenCorners, blurEffects, darkMode, fontFamily, language, hourFormat, dateOrder, dateFormat} | tojson);\n"
    + "const strings = \(($en[0] + ($ov[0] // {})) | pick | tojson);"
' > "$DIR/Generated.tmp.js"
mv -f "$DIR/Generated.tmp.js" "$DIR/Generated.js"
