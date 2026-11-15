#!/usr/bin/env bash
# 安裝啟動器與桌面捷徑（不會動到遊戲檔案）
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
CONF="$HOME/.config/win-classic-games"

mkdir -p "$BIN" "$APPS" "$CONF"
install -m 755 "$HERE/bin/win-game" "$BIN/win-game"
install -m 644 "$HERE/games.tsv" "$CONF/games.tsv"

rm -f "$APPS"/win-game-*.desktop 2>/dev/null || true

while IFS=$'\t' read -r key bottle exe en zh ver status; do
    case "$key" in \#*|"") continue ;; esac
    f="$APPS/win-game-$key.desktop"
    cat > "$f" <<EOF
[Desktop Entry]
Type=Application
Name=$zh ($en)
Name[en]=$en ($ver)
Comment=$ver — Windows classic game via Bottles
Exec=$BIN/win-game $key
Icon=applications-games
Terminal=false
Categories=Game;CardGame;
StartupNotify=false
EOF
    chmod 644 "$f"
done < "$CONF/games.tsv"

update-desktop-database "$APPS" 2>/dev/null || true
echo "已安裝：$BIN/win-game"
echo "桌面捷徑：$APPS/win-game-*.desktop"
echo "清單：win-game --list"
