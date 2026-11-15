# retro-games-linux

Run the **original** classic Windows games on Linux — Win95/98 16-bit games and Windows XP
games inside [Bottles](https://usebottles.com/) (Wine), plus the original MSN **Hexic**
Flash game through Ruffle.

No game binaries are shipped here (they are copyrighted). This repo contains the launchers,
the patch, and the notes needed to rebuild the setup from original media.

[English](#english) | [繁體中文](#繁體中文)

---

## English

### What's included

| Game | Version | How it runs | Status |
|---|---|---|---|
| Solitaire | Win95/98, 16-bit `SOL.EXE` | Wine (`winevdm`) | ✅ |
| FreeCell | Win95/98, 16-bit | Wine | ✅ |
| Minesweeper | Win95/98 | Wine | ✅ |
| Hearts | Win95/98 (needs `mfc40.dll`) | Wine | ✅ |
| Solitaire | Windows XP, 32-bit | Wine | ✅ |
| FreeCell | Windows XP | Wine | ✅ |
| Minesweeper | Windows XP | Wine | ✅ |
| Spider Solitaire | Windows XP | Wine | ✅ |
| Hearts | Windows XP | Wine | ⚠️ needs `mfc42u.dll` |
| 3D Pinball — Space Cadet | XP data + native engine | SpaceCadetPinball (Wine) | ✅ |
| Hexic | MSN Flash original | Ruffle + patched SWF | ✅ |

Full details, sources, controls and troubleshooting:
**[`docs/classic-win-games.md`](docs/classic-win-games.md)** ·
Hexic patch notes: **[`docs/hexic-msn-patch.md`](docs/hexic-msn-patch.md)**

### Requirements

* Bottles (`com.usebottles.bottles`) with runner **`soda-9.0-1`** (Wine 9 + lib32)
* `cabextract`, `unzip`, `xdotool`, `xwininfo`
* Ruffle (for Hexic), FFDec (only if you rebuild the Hexic patch)
* Host Wine 10 alone is **not** enough — it is pure WoW64 and cannot start 16-bit apps

### Quick start

```bash
git clone https://github.com/duckducktw/retro-games-linux
cd retro-games-linux

# 1. put the original files in place (see docs for download commands)
#    sources/win9x/   sol.exe freecell.exe winmine.exe mshearts.exe cards.dll mfc40.dll
#    sources/xp/      GAMES/CARDS/* GAMES/MINESWEEPER/* GAMES/PINBALL/*

# 2. create the bottles and copy the games in
./setup/build-bottles.sh sources

# 3. install the launcher + desktop entries
./install.sh

# 4. play
win-game --list
win-game sol9x
```

### Usage

```bash
win-game --list          # every key, title, exe path, status
win-game sol9x           # Win95/98 Solitaire
win-game spiderxp        # XP Spider Solitaire
pinball                  # 3D Pinball (native engine + original data)
hexic                    # MSN Hexic (saves progress, serves over http)
```

Each game also gets a desktop entry, so it shows up in the application menu.
Running a launcher twice does **not** open a second copy — it brings the existing window
to the front.

### Layout

```
games.tsv                 # key, bottle, exe, titles, status
bin/win-game              # generic launcher (--list / <key>)
bin/pinball               # 3D Pinball launcher (handles the unmapped-window quirk)
bin/hexic                 # MSN Hexic launcher (Ruffle)
bin/solitaire, bin/freecell
install.sh                # installs launcher + one .desktop per game
setup/build-bottles.sh    # creates bottles, copies original game files from <sources-dir>
desktop/                  # .desktop templates
docs/classic-win-games.md # full guide: sources, bottles, controls, troubleshooting
docs/hexic-msn-patch.md   # Hexic SWF patch explained
patch/hexic-msn/          # the four patched ActionScript files + apply.sh
patch/hexic-save/         # save/load patch (SharedObject) + apply.sh
```

### Notes and gotchas

* Win95/98 games are 16-bit NE binaries and need `winevdm` from a runner that still ships
  the 16-bit loader (`soda-9.0-1`). XP games are PE32 and run in a plain 64-bit prefix.
* `cards.dll` must match the game generation — XP card backs differ from Win95 ones, which
  is why the two generations live in separate bottles.
* Wine renders face-down cards as thin lines and Minesweeper's LED digits as broken blocks.
  Cosmetic only; the games are fully playable.
* Wine needs headroom: with the machine near full RAM, windows silently fail to map and
  `wineboot` hangs. See the troubleshooting section of the guide.

### License

MIT — see [LICENSE](LICENSE). Game binaries remain the property of their publishers and
are **not** distributed here.

---

## 繁體中文

### 內容

| 遊戲 | 版本 | 跑法 | 狀態 |
|---|---|---|---|
| 接龍 | Win95/98，16-bit `SOL.EXE` | Wine（`winevdm`） | ✅ |
| 新接龍 | Win95/98，16-bit | Wine | ✅ |
| 踩地雷 | Win95/98 | Wine | ✅ |
| 傷心小棧 | Win95/98（需 `mfc40.dll`） | Wine | ✅ |
| 接龍 | Windows XP，32-bit | Wine | ✅ |
| 新接龍 | Windows XP | Wine | ✅ |
| 踩地雷 | Windows XP | Wine | ✅ |
| 連環新接龍 | Windows XP | Wine | ✅ |
| 傷心小棧 | Windows XP | Wine | ⚠️ 缺 `mfc42u.dll` |
| ３Ｄ彈珠台 | XP 資料 + 原生引擎 | SpaceCadetPinball（Wine） | ✅ |
| Hexic | MSN Flash 原版 | Ruffle + patch 過的 SWF | ✅ |

完整說明（來源、瓶子設定、按鍵、疑難排解）：
**[`docs/classic-win-games.md`](docs/classic-win-games.md)**
Hexic patch 紀錄：**[`docs/hexic-msn-patch.md`](docs/hexic-msn-patch.md)**

### 需求

* Bottles（`com.usebottles.bottles`），runner 用 **`soda-9.0-1`**（Wine 9 + lib32）
* `cabextract`、`unzip`、`xdotool`、`xwininfo`
* Ruffle（Hexic 用）、FFDec（只有要重打 Hexic patch 才需要）
* 只用 host Wine 10 不夠——它是純 WoW64，開不了 16-bit 程式

### 快速開始

```bash
git clone https://github.com/duckducktw/retro-games-linux
cd retro-games-linux

# 1. 準備原版檔案（下載指令見 docs）
#    sources/win9x/   sol.exe freecell.exe winmine.exe mshearts.exe cards.dll mfc40.dll
#    sources/xp/      GAMES/CARDS/* GAMES/MINESWEEPER/* GAMES/PINBALL/*

# 2. 建瓶子並把遊戲複製進去
./setup/build-bottles.sh sources

# 3. 裝啟動器與桌面捷徑
./install.sh

# 4. 開始玩
win-game --list
win-game sol9x
```

### 用法

```bash
win-game --list          # 列出所有 key、名稱、路徑、狀態
win-game sol9x           # Win95/98 接龍
win-game spiderxp        # XP 連環新接龍
pinball                  # ３Ｄ彈珠台（原生引擎 + 原版資料）
hexic                    # MSN Hexic（可存檔，走本機 http）
```

每支遊戲都會裝一個桌面捷徑，開始選單裡也搜得到。同一支連點兩次不會開第二個，
只會把已開的視窗叫回前景。

### 目錄

```
games.tsv                 # key、瓶子、exe、名稱、狀態
bin/win-game              # 通用啟動器（--list / <key>）
bin/pinball               # 彈珠台啟動器（處理視窗 unmapped 的問題）
bin/hexic                 # MSN Hexic 啟動器（Ruffle）
bin/solitaire, bin/freecell
install.sh                # 安裝啟動器＋每支遊戲一個 .desktop
setup/build-bottles.sh    # 建瓶子、從 <sources-dir> 複製原版檔案
desktop/                  # .desktop 範本
docs/classic-win-games.md # 完整教學：來源、瓶子、按鍵、疑難排解
docs/hexic-msn-patch.md   # Hexic SWF patch 說明
patch/hexic-msn/          # 四個改過的 ActionScript 檔＋apply.sh
patch/hexic-save/         # 存檔／讀檔 patch（SharedObject）＋apply.sh
```

### 注意事項

* Win95/98 的遊戲是 16-bit NE，要靠 runner 裡的 `winevdm`（`soda-9.0-1` 有）。
  XP 遊戲是 PE32，普通 64-bit prefix 就能跑。
* `cards.dll` 要和遊戲世代對上——XP 牌背跟 Win95 不同，所以兩個世代分開兩個瓶子。
* Wine 會把蓋著的牌畫成一條細線、踩地雷的 LED 數字畫成破圖方塊。純外觀問題，
  遊戲本身完全可玩。
* Wine 需要記憶體餘裕：機器快滿的時候視窗會無聲開不起來、`wineboot` 會卡住。
  處理方式見指南的疑難排解段。

### 授權

MIT，見 [LICENSE](LICENSE)。遊戲執行檔的權利仍屬原發行商，本 repo **不** 散布。
