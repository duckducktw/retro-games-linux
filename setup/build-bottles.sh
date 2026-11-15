#!/usr/bin/env bash
# 建立 bottles 並把遊戲檔案複製進去
# 用法：build-bottles.sh <sources-dir>
#   <sources-dir>/win9x/  sol.exe freecell.exe winmine.exe mshearts.exe cards.dll mfc40.dll
#   <sources-dir>/win98/  SOL.EXE FREECELL.EXE WINMINE.EXE MSHEARTS.EXE CARDS.DLL
#   <sources-dir>/xp/     GAMES/CARDS/*.exe GAMES/CARDS/cards.dll GAMES/MINESWEEPER/winmine.exe GAMES/PINBALL/PINBALL.EXE
set -eu
SRC="${1:?sources dir}"
BOTTLES="${BOTTLES_CMD:-flatpak run --command=bottles-cli com.usebottles.bottles}"
BDIR="$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles"

new_bottle() {   # name windows_version
    [ -d "$BDIR/$1" ] || $BOTTLES new --bottle-name "$1" --environment application --arch win64 --runner soda-9.0-1
    sed -i "s/^Windows: .*/Windows: $2/" "$BDIR/$1/bottle.yml"
    grep -E "^Arch|^Windows" "$BDIR/$1/bottle.yml"
}

new_bottle Solitaire  winxp      # Win9x 的 16-bit 遊戲靠 soda 的 winevdm
new_bottle Win98Games win98
new_bottle WinXPGames winxp

# Win9x（16-bit Solitaire/FreeCell，32-bit Minesweeper/Hearts）
mkdir -p "$BDIR/Solitaire/drive_c/"{Solitaire,FreeCell,Minesweeper,Hearts}
cp "$SRC"/win9x/sol.exe       "$BDIR/Solitaire/drive_c/Solitaire/SOL.EXE"
cp "$SRC"/win9x/cards.dll     "$BDIR/Solitaire/drive_c/Solitaire/cards.dll"
cp "$SRC"/win9x/freecell.exe  "$BDIR/Solitaire/drive_c/FreeCell/FREECELL.EXE"
cp "$SRC"/win9x/cards.dll     "$BDIR/Solitaire/drive_c/FreeCell/cards.dll"
cp "$SRC"/win9x/winmine.exe   "$BDIR/Solitaire/drive_c/Minesweeper/winmine.exe"
cp "$SRC"/win9x/mshearts.exe  "$BDIR/Solitaire/drive_c/Hearts/mshearts.exe"
cp "$SRC"/win9x/mfc40.dll     "$BDIR/Solitaire/drive_c/Hearts/mfc40.dll"
cp "$SRC"/win9x/cards.dll     "$BDIR/Solitaire/drive_c/Hearts/cards.dll"

# Win98 內建遊戲（與 Win9x 不同 build）
mkdir -p "$BDIR/Win98Games/drive_c/Win98Games"
cp "$SRC"/win98/* "$BDIR/Win98Games/drive_c/Win98Games/"

# Windows XP 內建遊戲
mkdir -p "$BDIR/WinXPGames/drive_c/XPgames"/{CARDS,MINESWEEPER,PINBALL}
cp "$SRC"/xp/GAMES/CARDS/*.exe "$SRC"/xp/GAMES/CARDS/cards.dll "$BDIR/WinXPGames/drive_c/XPgames/CARDS/"
cp "$SRC"/xp/GAMES/MINESWEEPER/winmine.exe "$BDIR/WinXPGames/drive_c/XPgames/MINESWEEPER/"
cp "$SRC"/xp/GAMES/PINBALL/PINBALL.EXE     "$BDIR/WinXPGames/drive_c/XPgames/PINBALL/"

echo "完成。接著跑 ./install.sh"
