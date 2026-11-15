# Classic Windows games on Linux · 在 Linux 上跑經典 Windows 遊戲

[English](#english) | [繁體中文](#繁體中文)

## English

### What this is

Launchers + a manifest that run the **original** Microsoft game binaries (not remakes)
from Windows 95/98 and Windows XP inside [Bottles](https://usebottles.com/) (Wine),
plus the original MSN **Hexic** Flash game through Ruffle (see `hexic-msn-patch.md`).

`win-game` reads `games.tsv` and starts the right bottle + exe.

### Verified matrix

| key | Game | Version | Bottle | Status |
|---|---|---|---|---|
| `sol9x` | Solitaire | Win95/98, 16-bit `SOL.EXE` | Solitaire | ✅ works |
| `freecell9x` | FreeCell | Win95/98, 16-bit | Solitaire | ✅ works |
| `winmine9x` | Minesweeper | Win95/98 | Solitaire | ✅ works |
| `hearts9x` | Hearts | Win95/98 (needs `mfc40.dll`) | Solitaire | ✅ works |
| `solxp` | Solitaire | Windows XP, 32-bit | WinXPGames | ✅ works |
| `freecellxp` | FreeCell | Windows XP | WinXPGames | ✅ works |
| `winminexp` | Minesweeper | Windows XP | WinXPGames | ✅ works |
| `spiderxp` | Spider Solitaire | Windows XP | WinXPGames | ✅ works |
| `heartsxp` | Hearts | Windows XP | WinXPGames | ⚠️ needs `mfc42u.dll` (Unicode MFC 4.2) |
| `pinballexp` | 3D Pinball – Space Cadet | Windows XP | WinXPGames | ⚠️ starts, never maps a window |

### Why two bottles

* Win95/98 games are **16-bit NE** executables. They need Wine's `winevdm.exe` and a
  runner that still ships the 16-bit loader — Bottles `soda-9.0-1` (Wine 9 + lib32) does.
  Host Wine 10 is pure WoW64 and silently fails (`krnl386.exe16` init error).
* XP games are **PE32** and run natively in a 64-bit prefix, so they get their own bottle,
  which also keeps `cards.dll` versions apart (XP card backs ≠ Win95 card backs).

### Getting the original files

These are copyrighted, so this repo ships **no** binaries — only scripts and paths.

**Windows 95/98 (16-bit games)** — extract from the Win95 OSR2 CAB set:

```bash
for i in $(seq -w 2 22); do
  curl -O "https://archive.org/download/win95hdd_202109/Win95B/WIN95_$i.CAB"
done
cabextract -F "sol.exe" -F "freecell.exe" -F "winmine.exe" -F "mshearts.exe" \
           -F "cards.dll" -F "mfc40.dll" -d win9x WIN95_02.CAB
```

**Windows XP (32-bit games)**:

```bash
curl -LO "https://archive.org/download/windows-xp-default-games/Windows%20XP%20Default%20Games.zip"
unzip -q "Windows XP Default Games.zip" -d xp     # xp/GAMES/{CARDS,MINESWEEPER,PINBALL}
```

Then:

```bash
./setup/build-bottles.sh <sources-dir>   # creates bottles + copies files
./install.sh                             # launchers + desktop entries
win-game --list
```

### Known issues

* **`heartsxp`** — XP Hearts links MFC42u (Unicode). Drop a 32-bit `mfc42u.dll` into the
  bottle's `drive_c/windows/syswow64/` and it should start. XP's own copy lives in
  `system32` of an XP install.
* **`pinballexp`** — the exe runs, registry keys
  (`HKLM\Software\Microsoft\Plus!\The Microsoft Plus! for Windows XP`) are set, but it
  never creates a visible window. 3D Pinball needs DirectDraw + its table resource loaded
  through the Plus! registry; unresolved here.
* **Win98 game files** — a Win98 mirror of the 16-bit `SOL.EXE` (different MD5 from the
  Win95 build) creates a 111×1 off-screen window under `winevdm` in soda-9. Bottle runs
  the Win95/98 build instead; results are identical in practice.
* Single instance: `win-game` skips launching if the same bottle+exe is already running.

### Files

```
games.tsv                 # key, bottle, exe, titles, status
bin/win-game              # generic launcher (-–list)
install.sh                # installs launcher + .desktop entries per game
setup/build-bottles.sh    # creates bottles, copies game files from <sources-dir>
```

---

## 繁體中文

### 這是什麼

用 [Bottles](https://usebottles.com/)（Wine）跑 **原版** Windows 95/98 與 Windows XP
內建遊戲執行檔（不是重製版），另外 MSN 原版 **Hexic** 走 Ruffle（見 `hexic-msn-patch.md`）。

`win-game` 讀 `games.tsv`，自動挑對瓶子與 exe 啟動。

### 實測結果

| key | 遊戲 | 版本 | 瓶子 | 狀態 |
|---|---|---|---|---|
| `sol9x` | 接龍 | Win95/98，16-bit `SOL.EXE` | Solitaire | ✅ 可玩 |
| `freecell9x` | 新接龍 | Win95/98，16-bit | Solitaire | ✅ 可玩 |
| `winmine9x` | 踩地雷 | Win95/98 | Solitaire | ✅ 可玩 |
| `hearts9x` | 傷心小棧 | Win95/98（需 `mfc40.dll`） | Solitaire | ✅ 可玩 |
| `solxp` | 接龍 | Windows XP，32-bit | WinXPGames | ✅ 可玩 |
| `freecellxp` | 新接龍 | Windows XP | WinXPGames | ✅ 可玩 |
| `winminexp` | 踩地雷 | Windows XP | WinXPGames | ✅ 可玩 |
| `spiderxp` | 連環新接龍 | Windows XP | WinXPGames | ✅ 可玩 |
| `heartsxp` | 傷心小棧 | Windows XP | WinXPGames | ⚠️ 缺 `mfc42u.dll` |
| `pinballexp` | ３Ｄ彈珠台 | Windows XP | WinXPGames | ⚠️ 起得來但沒有視窗 |

### 為什麼要兩個瓶子

* Win95/98 的遊戲是 **16-bit NE** 執行檔，要靠 Wine 的 `winevdm.exe`，而且 runner 必須
  還帶 16-bit loader。Bottles 的 `soda-9.0-1`（Wine 9 + lib32）可以；host Wine 10 是純
  WoW64，會無聲失敗（`krnl386.exe16` 初始化錯誤）。
* XP 遊戲是 **PE32**，64-bit prefix 直接跑得動，所以另外開一瓶；順便讓 `cards.dll`
  版本分開（XP 牌背跟 95 牌背不同）。

### 原版檔案哪裡來

有版權，所以 repo **不放**任何執行檔，只放腳本與路徑。

**Win95/98（16-bit 遊戲）** 從 Win95 OSR2 的 CAB 抽：

```bash
for i in $(seq -w 2 22); do
  curl -O "https://archive.org/download/win95hdd_202109/Win95B/WIN95_$i.CAB"
done
cabextract -F "sol.exe" -F "freecell.exe" -F "winmine.exe" -F "mshearts.exe" \
           -F "cards.dll" -F "mfc40.dll" -d win9x WIN95_02.CAB
```

**Windows XP（32-bit 遊戲）**：

```bash
curl -LO "https://archive.org/download/windows-xp-default-games/Windows%20XP%20Default%20Games.zip"
unzip -q "Windows XP Default Games.zip" -d xp     # xp/GAMES/{CARDS,MINESWEEPER,PINBALL}
```

之後：

```bash
./setup/build-bottles.sh <sources-dir>   # 建瓶子＋複製檔案
./install.sh                             # 裝啟動器與桌面捷徑
win-game --list
```

### 已知問題

* **`heartsxp`** — XP 版傷心小棧連到 MFC42u（Unicode 版）。把 32-bit `mfc42u.dll` 丟進
  瓶子的 `drive_c/windows/syswow64/` 就能起來（XP 安裝片的 `system32` 裡有）。
* **`pinballexp`** — exe 有跑、Plus! 機碼也寫了
  （`HKLM\Software\Microsoft\Plus!\The Microsoft Plus! for Windows XP`），但就是不開視窗。
  ３Ｄ彈珠台要 DirectDraw 加上從 Plus! 機碼載入球檯資源，這條未解。
* **Win98 檔案** — 另一個鏡像的 16-bit `SOL.EXE`（MD5 與 Win95 版不同）在 soda-9 的
  `winevdm` 下只會產生 111×1 的視窗外框。實務上直接用 Win95/98 build，玩起來一樣。
* 單實例：同一個瓶子＋同一支 exe 已在跑時，`win-game` 不會再開一個。
