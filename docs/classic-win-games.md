# Classic Windows games on Linux · 在 Linux 上跑經典 Windows 遊戲

[English](#english) | [繁體中文](#繁體中文)

---

## English

### What this is

Launchers + a manifest that run the **original** Microsoft game binaries (not remakes)
from Windows 95/98 and Windows XP inside [Bottles](https://usebottles.com/) (Wine), plus
the original MSN **Hexic** Flash game through Ruffle (see `hexic-msn-patch.md`).

`win-game` reads `games.tsv`, picks the right bottle, and starts the right exe.

### Verified matrix

| launcher / key | Game | Version | Bottle | Status |
|---|---|---|---|---|
| `sol9x` | Solitaire | Win95/98, 16-bit `SOL.EXE` | Solitaire | ✅ works |
| `freecell9x` | FreeCell | Win95/98, 16-bit | Solitaire | ✅ works |
| `winmine9x` | Minesweeper | Win95/98 | Solitaire | ✅ works |
| `hearts9x` | Hearts | Win95/98 (needs `mfc40.dll`) | Solitaire | ✅ works |
| `solxp` | Solitaire | Windows XP, 32-bit | WinXPGames | ✅ works |
| `freecellxp` | FreeCell | Windows XP | WinXPGames | ✅ works |
| `winminexp` | Minesweeper | Windows XP | WinXPGames | ✅ works |
| `spiderxp` | Spider Solitaire | Windows XP | WinXPGames | ✅ works |
| `heartsxp` | Hearts | Windows XP | WinXPGames | ⚠️ needs `mfc42u.dll` |
| `pinball` | 3D Pinball — Space Cadet | XP data + native engine | WinXPGames | ✅ works |
| `hexic` | Hexic | MSN Flash original | Ruffle (no Wine) | ✅ works |

`win-game --list` lists the Wine entries; `pinball` and `hexic` are separate launchers
(`bin/pinball`, `bin/hexic`) because they do not go through Bottles' `run`.

### Requirements

| Need | Why |
|---|---|
| Bottles (`com.usebottles.bottles`) | sandbox + per-game prefixes |
| runner `soda-9.0-1` (Wine 9 + lib32) | the only runner here that still ships the 16-bit loader |
| `cabextract` | pull the Win95/98 games out of the OSR2 CAB set |
| `unzip`, `curl` | fetch the XP game package / Hexic zip |
| `xdotool`, `xwininfo` | single-instance window handling, screenshots, debugging |
| Ruffle nightly | runs the Hexic SWF natively |
| FFDec (optional) | only if you rebuild the Hexic patch |

Host Wine 10 is **not** usable for the 16-bit games: it is pure WoW64, `krnl386.exe16`
fails to initialise and the app exits with no window and no error.

### Getting the original files

These are copyrighted, so this repo ships **no** binaries — only scripts and paths.

#### Windows 95/98 (16-bit games)

```bash
mkdir -p sources/win9x && cd sources
for i in $(seq -w 2 22); do
  curl -O "https://archive.org/download/win95hdd_202109/Win95B/WIN95_$i.CAB"
done
cabextract -F "sol.exe" -F "freecell.exe" -F "winmine.exe" -F "mshearts.exe" \
           -F "cards.dll" -F "mfc40.dll" -d ../sources/win9x WIN95_02.CAB
```

`mshearts.exe` (Win95 Hearts) is a 32-bit MFC 4.0 app: it needs `mfc40.dll` **next to the
exe** and a 16-bit `cards.dll` for the card faces.

#### Windows XP (32-bit games)

```bash
curl -LO "https://archive.org/download/windows-xp-default-games/Windows%20XP%20Default%20Games.zip"
unzip -q "Windows XP Default Games.zip" -d sources      # -> sources/GAMES/{CARDS,MINESWEEPER,PINBALL}

# the full 3D Pinball data set (table + MIDI + all SOUND*.WAV) lives in another package:
curl -LO "https://archive.org/download/3-windows-xp-games/3%20windows%20XP%20games.zip"
unzip -q "3 windows XP games.zip" -d pinball-extra      # -> pinball-extra/pinball/{PINBALL.DAT,PINBALL.MID,...}
```

#### Windows 98 build (optional, not included)

A separate Win98 mirror of the 16-bit `SOL.EXE` (different MD5 from the Win95 build) runs
under `winevdm` but only ever creates a 111×1 off-screen window, so it is not supported.
The Win95/98 build is what the matrix ships; gameplay is identical.

### Bottle setup

`setup/build-bottles.sh <sources-dir>` does all of this; the manual equivalent:

```bash
flatpak run --command=bottles-cli com.usebottles.bottles new \
  --bottle-name Solitaire --environment application --arch win64 --runner soda-9.0-1
flatpak run --command=bottles-cli com.usebottles.bottles new \
  --bottle-name WinXPGames --environment application --arch win64 --runner soda-9.0-1
```

* **`Arch: win64`** — a `win32` prefix collides with the runner's `WINEARCH`; keep the
  prefix 64-bit and let `winevdm` handle the 16-bit binaries.
* **`Windows:`** — `winxp` works for both bottles (the Win9x games only care about
  `winevdm`, the XP games want XP semantics).
* **Two bottles, not one** — 16-bit and 32-bit games, and Win95 vs XP `cards.dll` sets,
  must not share a prefix.

Layout the script creates:

```
Solitaire/drive_c/  Solitaire/SOL.EXE + cards.dll
                    FreeCell/FREECELL.EXE + cards.dll
                    Minesweeper/winmine.exe
                    Hearts/mshearts.exe + mfc40.dll + cards.dll
WinXPGames/drive_c/ XPgames/CARDS/{sol,freecell,spider,mshearts}.exe + cards.dll
                    XPgames/MINESWEEPER/winmine.exe
                    XPgames/PINBALL/PINBALL.EXE + full data set
```

### Usage

```bash
./install.sh                 # installs ~/.local/bin/win-game + one .desktop per game
win-game --list              # key, title, exe, status
win-game sol9x               # launch
win-game sol98               # (removed, see above)
pinball                      # 3D Pinball, own launcher
hexic                        # MSN Hexic, own launcher
```

`win-game` behaviour:

* looks the key up in `~/.config/win-classic-games/games.tsv`
* **single instance** — if the same bottle + exe is already running it exits silently, so
  double-clicking a desktop icon will not spawn a second Wine session (a second session in
  one prefix is what breaks window mapping)
* `install.sh` regenerates every `win-game-*.desktop`, removing stale ones

### Controls

| Game | Controls |
|---|---|
| Solitaire (Win9x / XP) | `Game ▸ Deal` = F2 (re-deal, there is no level select), `Deal` drag, double-click to auto-play, `Deck ▸ Select Card Back` for other backs, `Options` for Keep score / Draw one / Draw three / Timed game. Undo is single-step by design. |
| FreeCell (Win9x / XP) | `Game ▸ New` F2, `Select Game` F3, `Undo`, 4 free cells + 8 columns |
| Minesweeper | left click reveal, right click flag, `Game ▸ Beginner / Intermediate / Expert / Custom`, F2 new |
| Hearts (Win9x) | pass 3 cards, `Game ▸ New Game`, `Options` for game rules |
| Spider (XP) | `Game ▸ New Game` F2, `Options ▸ Difficulty` (1 / 2 / 4 suits), `Undo` |
| 3D Pinball | Space launches the ball, `Z` / `/` are the flippers, `Options ▸ Player Controls` shows and rebinds everything |
| Hexic | drag a gem in a circle to rotate a cluster; menu/tutorial in-game |

### Required data files

| Game | Files |
|---|---|
| Win9x Solitaire / FreeCell | `sol.exe` / `freecell.exe` + 16-bit `cards.dll` (same folder) |
| Win9x Minesweeper | `winmine.exe` |
| Win9x Hearts | `mshearts.exe` + `mfc40.dll` + `cards.dll` |
| XP card games | `CARDS/*.exe` + `CARDS/cards.dll` |
| XP Minesweeper | `MINESWEEPER/winmine.exe` |
| 3D Pinball | `PINBALL.DAT`, `FONT.DAT`, `PINBALL.MID`, `PINBALL2.MID`, `SOUND*.WAV` (+ `SpaceCadetPinball.exe`, `SDL2.dll`, `SDL2_mixer.dll`) |
| Hexic | `Hexic2.swf` + `Hexic.xml` + `sounds/` (see `hexic-msn-patch.md`) |

### Troubleshooting

Every row below was hit while building this; they are ordered by how often they bite.

| Symptom | Cause | Fix |
|---|---|---|
| A game window exists but is `111x1` at a nonsense position, `IsUnMapped` | two Wine sessions alive in the same prefix (a killed process left `explorer.exe`/`services.exe` behind) | kill every Wine process of that bottle, then launch once: `pkill -9 -f "bottles-cli run -b <Bottle>"`, `killall -9 <exe>` |
| No window at all and the log is empty | low memory — the window never maps; `wineboot` times out too | free RAM (close the Minecraft client / any local server) and retry; check with `free -m` |
| `wine: could not load kernel32.dll`, or `wineboot` hangs | stale Wine server socket in `/tmp/.wine-<uid>` | `pkill -9 -f wineserver; rm -rf /tmp/.wine-1000`, retry |
| `nodrv_CreateWindow … The explorer process failed to start` | same stale-session problem, seen under Xvfb | restart the bottle after the cleanup above |
| Face-down cards render as thin lines | Wine + 16-bit `cards.dll` bitmap blit | cosmetic, ignore — cards behave normally |
| Minesweeper's red LED digits look broken | same bitmap font issue | cosmetic, ignore |
| XP Hearts exits immediately | needs MFC42**u** (Unicode). `mfc40.dll` is not enough | drop a 32-bit `mfc42u.dll` into `<bottle>/drive_c/windows/syswow64/` |
| 3D Pinball: original `PINBALL.EXE` runs but never shows a window, no error | the exe initialises (it even writes its `Plus!` registry keys) but never maps a window under Wine | use `bin/pinball` (SpaceCadetPinball engine + original data). It also maps/activates the window, which starts out unmapped |
| 3D Pinball: "Could not load game data — The .dat file is missing" | `PINBALL.DAT` not next to the engine | copy the whole XP `PINBALL` data set into `~/Applications/Pinball/` |
| Hexic freezes, CPU pegged, no redraw | full ActionScript recompile caused an AVM1 infinite loop | use the minimal 4-script patch — see `hexic-msn-patch.md` |
| Killing Wine also killed LINE | `pkill -f wine…` matches every bottle's processes | restart LINE with `bottles-cli run -b Wine -e 'C:\line-launch.bat'`; kill by bottle-specific pattern instead |

Debug helpers used throughout:

```bash
DISPLAY=:0 XAUTHORITY=/run/user/1000/xauth_nPlHQa xwininfo -root -tree | grep -i '<title>'
DISPLAY=:0 XAUTHORITY=/run/user/1000/xauth_nPlHQa xprop -id <win> | grep _NET_WM_PID
flutter=none; flatpak run --command=bottles-cli com.usebottles.bottles run -b <Bottle> -e '<exe>'
```

`bottles-cli run` never prints Wine's own stderr in a useful place when a window fails —
run the runner binary directly to see errors:

```bash
R=~/.var/app/com.usebottles.bottles/data/bottles/runners/soda-9.0-1
WINEPREFIX=~/.var/app/com.usebottles.bottles/data/bottles/bottles/<Bottle> \
  DISPLAY=:0 "$R/bin/wine" '<exe>'
```

### Known limitations

* No level select in Win95 Solitaire — `Deal` only re-deals randomly.
* `Undo` is one step (Win95 design), then greys out.
* XP Hearts and the Win98 16-bit build are documented but not working (see above).
* The two cosmetic rendering issues (hidden cards, LED digits) have no fix short of
  replacing Wine's GDI blit path.
* Fonts in the card games are Wine's substitutes; card *faces* come from the original
  `cards.dll`, so they are authentic.

### Files

```
games.tsv                 # key, bottle, exe, titles, status
bin/win-game              # generic launcher (--list / <key>)
bin/pinball               # 3D Pinball launcher (maps the unmapped SDL window)
bin/hexic                 # MSN Hexic launcher (Ruffle, single instance)
install.sh                # launcher + one .desktop per game
setup/build-bottles.sh    # bottles + copy original files from <sources-dir>
docs/hexic-msn-patch.md   # why the SWF needs patching and how
patch/hexic-msn/          # the 4 patched scripts + apply.sh
```

---

## 繁體中文

### 這是什麼

用 [Bottles](https://usebottles.com/)（Wine）跑 **原版** Windows 95/98 與 Windows XP
內建遊戲執行檔（不是重製版），另外 MSN 原版 **Hexic** 走 Ruffle（見 `hexic-msn-patch.md`）。

`win-game` 讀 `games.tsv`，自動挑對瓶子與 exe 啟動。

### 實測結果

| 啟動器 / key | 遊戲 | 版本 | 瓶子 | 狀態 |
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
| `pinball` | ３Ｄ彈珠台 | XP 資料 + 原生引擎 | WinXPGames | ✅ 可玩 |
| `hexic` | Hexic | MSN Flash 原版 | Ruffle（不用 Wine） | ✅ 可玩 |

`win-game --list` 只列走 Bottles 的遊戲；`pinball` 與 `hexic` 是獨立啟動器
（`bin/pinball`、`bin/hexic`），不經過 Bottles 的 `run`。

### 需求

| 需要 | 為什麼 |
|---|---|
| Bottles（`com.usebottles.bottles`） | 沙盒 + 每支遊戲各自的 prefix |
| runner `soda-9.0-1`（Wine 9 + lib32） | 這裡唯一還帶 16-bit loader 的 runner |
| `cabextract` | 從 Win95 OSR2 CAB 抽出遊戲 |
| `unzip`、`curl` | 抓 XP 遊戲包與 Hexic zip |
| `xdotool`、`xwininfo` | 單實例視窗處理、截圖、除錯 |
| Ruffle nightly | 原生跑 Hexic SWF |
| FFDec（選用） | 只有要重打 Hexic patch 才需要 |

host Wine 10 **不能**用來跑 16-bit 遊戲：它是純 WoW64，`krnl386.exe16` 初始化失敗，
程式會無聲結束、沒有視窗也沒有錯誤訊息。

### 原版檔案哪裡來

這些有版權，所以 repo **不放**任何執行檔，只放腳本與路徑。

#### Windows 95/98（16-bit 遊戲）

```bash
mkdir -p sources/win9x && cd sources
for i in $(seq -w 2 22); do
  curl -O "https://archive.org/download/win95hdd_202109/Win95B/WIN95_$i.CAB"
done
cabextract -F "sol.exe" -F "freecell.exe" -F "winmine.exe" -F "mshearts.exe" \
           -F "cards.dll" -F "mfc40.dll" -d ../sources/win9x WIN95_02.CAB
```

`mshearts.exe`（Win95 傷心小棧）是 32-bit MFC 4.0 程式：需要 `mfc40.dll` **跟 exe 放一起**，
牌面則要 16-bit `cards.dll`。

#### Windows XP（32-bit 遊戲）

```bash
curl -LO "https://archive.org/download/windows-xp-default-games/Windows%20XP%20Default%20Games.zip"
unzip -q "Windows XP Default Games.zip" -d sources      # -> sources/GAMES/{CARDS,MINESWEEPER,PINBALL}

# ３Ｄ彈珠台完整資料（球檯 + MIDI + 全部 SOUND*.WAV）在另一包：
curl -LO "https://archive.org/download/3-windows-xp-games/3%20windows%20XP%20games.zip"
unzip -q "3 windows XP games.zip" -d pinball-extra      # -> pinball-extra/pinball/{PINBALL.DAT,PINBALL.MID,...}
```

#### Windows 98 版（選用，未納入）

另一個鏡像的 16-bit `SOL.EXE`（MD5 與 Win95 build 不同）在 `winevdm` 下跑得起來，
但只會產生 111×1 的離屏視窗外框，所以不支援。清單裡用的是 Win95/98 build，玩起來一樣。

### 瓶子設定

`setup/build-bottles.sh <sources-dir>` 會全部做完；手動等價指令：

```bash
flatpak run --command=bottles-cli com.usebottles.bottles new \
  --bottle-name Solitaire --environment application --arch win64 --runner soda-9.0-1
flatpak run --command=bottles-cli com.usebottles.bottles new \
  --bottle-name WinXPGames --environment application --arch win64 --runner soda-9.0-1
```

* **`Arch: win64`** — `win32` prefix 會和 runner 的 `WINEARCH` 衝突；保持 64-bit，
  16-bit 程式交給 `winevdm`。
* **`Windows:`** — 兩個瓶子都設 `winxp` 即可（Win9x 遊戲只在意 `winevdm`，
  XP 遊戲要 XP 行為）。
* **兩個瓶子，不要合併** — 16-bit 與 32-bit 遊戲、以及 Win95 與 XP 的 `cards.dll`
  不能共用同一個 prefix。

腳本建立的結構：

```
Solitaire/drive_c/  Solitaire/SOL.EXE + cards.dll
                    FreeCell/FREECELL.EXE + cards.dll
                    Minesweeper/winmine.exe
                    Hearts/mshearts.exe + mfc40.dll + cards.dll
WinXPGames/drive_c/ XPgames/CARDS/{sol,freecell,spider,mshearts}.exe + cards.dll
                    XPgames/MINESWEEPER/winmine.exe
                    XPgames/PINBALL/PINBALL.EXE + 完整資料
```

### 用法

```bash
./install.sh                 # 裝 ~/.local/bin/win-game + 每支遊戲一個 .desktop
win-game --list              # key、名稱、路徑、狀態
win-game sol9x               # 啟動
pinball                      # ３Ｄ彈珠台，自己的啟動器
hexic                        # MSN Hexic，自己的啟動器
```

`win-game` 行為：

* 到 `~/.config/win-classic-games/games.tsv` 查 key
* **單實例** — 同一個瓶子＋同一支 exe 已在跑就直接結束，所以桌面圖示連點兩次不會
  開出第二個 Wine session（同一個 prefix 有兩個 session 正是視窗映射壞掉的主因）
* `install.sh` 每次都會重建所有 `win-game-*.desktop`，並清掉舊的

### 按鍵與玩法

| 遊戲 | 操作 |
|---|---|
| 接龍（Win9x / XP） | `Game ▸ Deal` = F2（只是重發新局，沒有選關卡）、拖曳出牌、雙擊自動送牌、`Deck ▸ Select Card Back` 換牌背、`Options` 有 Keep score / Draw one / Draw three / Timed game。Undo 只有一步是原版設計 |
| 新接龍（Win9x / XP） | `Game ▸ New` F2、`Select Game` F3、`Undo`，四個暫存格 + 八列 |
| 踩地雷 | 左鍵翻格、右鍵插旗、`Game ▸ Beginner / Intermediate / Expert / Custom`、F2 新局 |
| 傷心小棧（Win9x） | 傳三張牌、`Game ▸ New Game`、`Options` 調規則 |
| 連環新接龍（XP） | `Game ▸ New Game` F2、`Options ▸ Difficulty`（1 / 2 / 4 花色）、`Undo` |
| ３Ｄ彈珠台 | 空白鍵發球、`Z` 與 `/` 是左右擋板、`Options ▸ Player Controls` 可看與改鍵 |
| Hexic | 拖著寶石繞圈旋轉整群；教學在遊戲內 |

### 各遊戲需要的檔案

| 遊戲 | 檔案 |
|---|---|
| Win9x 接龍 / 新接龍 | `sol.exe` / `freecell.exe` + 16-bit `cards.dll`（同資料夾） |
| Win9x 踩地雷 | `winmine.exe` |
| Win9x 傷心小棧 | `mshearts.exe` + `mfc40.dll` + `cards.dll` |
| XP 紙牌類 | `CARDS/*.exe` + `CARDS/cards.dll` |
| XP 踩地雷 | `MINESWEEPER/winmine.exe` |
| ３Ｄ彈珠台 | `PINBALL.DAT`、`FONT.DAT`、`PINBALL.MID`、`PINBALL2.MID`、`SOUND*.WAV`（＋ `SpaceCadetPinball.exe`、`SDL2.dll`、`SDL2_mixer.dll`） |
| Hexic | `Hexic2.swf` + `Hexic.xml` + `sounds/`（見 `hexic-msn-patch.md`） |

### 疑難排解

下面每一條都是這次實際踩到的，按發生頻率排序。

| 症狀 | 原因 | 解法 |
|---|---|---|
| 視窗存在但大小是 `111x1`、位置亂跳、`IsUnMapped` | 同一個 prefix 裡有兩個 Wine session（被殺掉的進程留下 `explorer.exe`／`services.exe`） | 把該瓶子的 Wine 進程全殺掉再開一次：`pkill -9 -f "bottles-cli run -b <瓶子>"`、`killall -9 <exe>` |
| 完全沒有視窗、log 也空 | 記憶體不足，視窗根本沒 map；`wineboot` 也會 timeout | 先騰出記憶體（關掉 Minecraft 客戶端／本機伺服器）再試，用 `free -m` 確認 |
| `wine: could not load kernel32.dll`，或 `wineboot` 卡住 | `/tmp/.wine-<uid>` 裡的 Wine server socket 是舊的 | `pkill -9 -f wineserver; rm -rf /tmp/.wine-1000` 後重試 |
| `nodrv_CreateWindow … The explorer process failed to start` | 同上，Xvfb 下也會出現 | 清理後重開瓶子 |
| 蓋著的牌只畫成一條細線 | Wine 對 16-bit `cards.dll` 的 bitmap blit 問題 | 純外觀，牌的行為正常 |
| 踩地雷紅色 LED 數字變破圖方塊 | 同樣是 bitmap 字型問題 | 純外觀，可正常遊玩 |
| XP 傷心小棧一開就結束 | 需要 MFC42**u**（Unicode 版），`mfc40.dll` 不夠 | 把 32-bit `mfc42u.dll` 放進 `<瓶子>/drive_c/windows/syswow64/` |
| ３Ｄ彈珠台原版 `PINBALL.EXE` 有跑但永遠不開視窗、沒有錯誤 | 這支 exe 在 Wine 下會初始化（甚至寫了 `Plus!` 機碼）卻從不 map 視窗 | 改用 `bin/pinball`（SpaceCadetPinball 引擎 + 原版資料），它也會自動把一開始 unmapped 的視窗 map 起來 |
| ３Ｄ彈珠台跳出「Could not load game data — The .dat file is missing」 | `PINBALL.DAT` 沒跟引擎放在一起 | 把 XP 的 `PINBALL` 整套資料複製到 `~/Applications/Pinball/` |
| Hexic 卡死、CPU 滿載、畫面不重繪 | 全量重新編譯 ActionScript 造成 AVM1 無限迴圈 | 用只改 4 個腳本的最小 patch，見 `hexic-msn-patch.md` |
| 殺 Wine 連 LINE 一起被殺 | `pkill -f wine…` 會命中所有瓶子的進程 | 用 `bottles-cli run -b Wine -e 'C:\line-launch.bat'` 重開 LINE；平時只殺指定瓶子的進程 |

除錯常用指令：

```bash
DISPLAY=:0 XAUTHORITY=/run/user/1000/xauth_nPlHQa xwininfo -root -tree | grep -i '<標題>'
DISPLAY=:0 XAUTHORITY=/run/user/1000/xauth_nPlHQa xprop -id <win> | grep _NET_WM_PID
flatpak run --command=bottles-cli com.usebottles.bottles run -b <瓶子> -e '<exe>'
```

視窗開不起來時 `bottles-cli run` 不會顯示 Wine 自己的 stderr，要直接跑 runner：

```bash
R=~/.var/app/com.usebottles.bottles/data/bottles/runners/soda-9.0-1
WINEPREFIX=~/.var/app/com.usebottles.bottles/data/bottles/bottles/<瓶子> \
  DISPLAY=:0 "$R/bin/wine" '<exe>'
```

### 已知限制

* Win95 接龍沒有選關卡，`Deal` 只是隨機重發。
* `Undo` 只能退一步（原版設計），退完變灰色。
* XP 傷心小棧與 Win98 16-bit build 已寫進文件，但目前還不能跑（見上）。
* 兩個外觀問題（蓋牌、LED 數字）除非換掉 Wine 的 GDI blit 路徑，否則無解。
* 紙牌字型用 Wine 的替代字型；**牌面**來自原版 `cards.dll`，所以是原版的。

### 檔案

```
games.tsv                 # key、瓶子、exe、名稱、狀態
bin/win-game              # 通用啟動器（--list / <key>）
bin/pinball               # ３Ｄ彈珠台啟動器（處理 unmapped 視窗）
bin/hexic                 # MSN Hexic 啟動器（Ruffle，單實例）
install.sh                # 安裝啟動器＋每支遊戲一個 .desktop
setup/build-bottles.sh    # 建瓶子、從 <sources-dir> 複製原版檔案
docs/hexic-msn-patch.md   # SWF 為什麼要 patch、怎麼 patch
patch/hexic-msn/          # 四個改過的腳本＋apply.sh
```
