# MSN Hexic — patch notes

[English](#english) | [繁體中文](#繁體中文)

---

## English

### Source

- Flashpoint game id: `c494046c-66e2-4ef8-a760-a3838f837b80`
- Zip: `https://games.flashmuseum.net/c494046c-66e2-4ef8-a760-a3838f837b80.zip`
  - A plain `curl` returns garbage; the download must be fetched from a
    `flashmuseum.net` page with `fetch(url, {credentials: 'include'})`.
- SWF inside: `content/zone.msn.com/bingame/hxic/default/Hexic2.swf`
  (98 KB, Flash 6, stage 400x325).
- `Hexic.xml` (localization) and `sounds/` must sit next to the SWF, otherwise
  the game never leaves the splash screen.

### Why it needs a patch

The MSN build is a *client module* for the old `zone.msn.com/gameplayer` shell.
After the splash it repeatedly sends `fscommand("SessionReady", ...)` and waits
for the host to answer:

```
GameClient.SetVariable("/EM:data0", xmlData);
GameClient.TCallLabel("/EM", "Init");
```

The host is long gone, so the game sits on the splash forever and ignores every
click — easy to misdiagnose as "mouse input is not reaching the window".

The payload the host sends is trivial anyway
(`<data><game code="hxic"></game></data>`) and `InitSession()` never reads it,
so the whole handshake can simply be removed.

### What the patch changes

1. `frame_6/DoAction.as` — inside the splash `onEnterFrame`, the SessionReady
   retry loop becomes:

   ```actionscript
   this.onEnterFrame = null;
   _root._ReceivedSessionStart = true;
   _root.InitSession();
   _root.gotoAndStop("Menu");
   ```

   and `_loc1_.SessionUpdate(); fscommand("GetBackground");` becomes
   `_root.SessionUpdate();`

2. `frame_13/PlaceObject2_215_144` (Start Normal Mode) and `_215_136`
   (Start Timed Mode) — `fscommand("GameReady", ...)` plus the conditional
   `InitGame(true)` is replaced with `_loc1_.gotoAndStop("Active");`

3. `frame_108/PlaceObject2_296_135` (Confirm → Yes) — same replacement.

Root timeline: frame 1 = `Active` (board), 6 = `Splash`, 13 = `Menu`
(`Fr = {Active:1, Splash:6, Menu:13}`). Entering frame 1 with `_SplashPlayed`
set automatically runs `InitGame(true)`.

### Applying

```
./apply.sh Hexic2.orig.swf Hexic2.patched.swf /path/to/ffdec.jar
```

FFDec: `ffdec_<ver>.zip` from `jindrapetrik/jpexs-decompiler` releases; a JRE is
required. Note the argument order of `-importScript`: **infile, outfile,
scripts-folder** — reversing it fails with `I/O error during reading`.

**Import only the four modified scripts.** Feeding the whole exported `scripts/`
folder makes FFDec recompile all 62 scripts; the bytecode then changes across
half the file and the game was observed freezing mid-play in an infinite AVM1
loop (main thread pinned at ~60% CPU, window stops repainting).

### Running

```
HEXIC_DIR=~/Applications/Hexic ~/.local/bin/hexic
```

Ruffle with `--graphics vulkan` (the `gl` backend sometimes opens no window) and
an empty `WAYLAND_DISPLAY`. Without the save patch `file://` is fine; with it the
movie must be served over `http://` (see below).

### Save / load patch (`patch/hexic-save`)

The MSN build cannot save anything: exporting all 62 scripts turns up no
`SharedObject` call at all. Progress lived on zone.msn.com, pushed there by
`fscommand("SessionUpdate"/"GameEnd"/"GameBreak")` to the gameplayer shell, so
every launch starts at Level 1 with 0 points.

`patch/hexic-save` adds a local save on top of the handshake patch, using the
AVM1 SharedObject `hexic_save`:

| Script | Role |
| --- | --- |
| `frame_6/DoAction.as` | splash: read `hexic_save` into `_root._SavedLevel` / `_SavedScore` |
| `frame_13/PlaceObject2_215_128` | Resume Game button: enabled when a save exists, restores `_InitialLevel` and `_Score` before `gotoAndStop("Active")` |
| `frame_146/DoAction.as`, `frame_153/DoAction.as` | level-up transition frames: write `_Level` / `_Score`, then `flush()` |

Things that bite:

- **Both** `frame_146` and `frame_153` run during the level-up animation. Patching
  only `frame_153` silently never saves.
- `createEmptyMovieClip()` depth must stay inside the AVM1 range (-16383..16383).
  `98765` is ignored without an error, so the one-frame score restore never ran;
  use `16000`.
- The LSO lands in
  `~/.local/share/ruffle/SharedObjects/127.0.0.1/<movie name>/hexic_save.sol`.
  The directory is keyed by the movie **file name**, so renaming the SWF starts
  with an empty save.
- `file://` is not usable: Ruffle refuses SharedObject there with
  `SharedObject.get_local: Invalid path with .. segments`. Serve the folder over
  HTTP — that is exactly what `bin/hexic` does (and it picks a free port).
- Verified: a save with `_Level=3 / _Score=5000` resumes as Level 4 (the HUD shows
  `_Level + 1`) with exactly 5000 points, and the score stays put while idle.
  Resuming at a very high level (8+) makes the score run away — those level
  tables do not expect to be entered that way, so treat such saves as throwaway.

### Known issues

- Ruffle stubs `Sound.getBytesLoaded()` (returns 0), so music may stay silent.
- Window is fixed at 400x325; scale it from Ruffle's *View* menu.
- The native "Hexic Deluxe" build (`HexicDeluxe.exe`) is a dead end under Wine:
  a native shell hosting a Flash ActiveX control. Licensing can be completed
  (`Key Valid`) but only a 113x2 hidden window is ever created — installing and
  registering `Flash.ocx`, switching to a virtual desktop or emulating WinXP all
  made no difference.

---

## 繁體中文

### 來源

- Flashpoint game id：`c494046c-66e2-4ef8-a760-a3838f837b80`
- zip：`https://games.flashmuseum.net/c494046c-66e2-4ef8-a760-a3838f837b80.zip`
  - 直接 `curl` 會拿到失敗內容；要在 `flashmuseum.net` 頁面用
    `fetch(url, {credentials: 'include'})` 下載。
- zip 內的 SWF：`content/zone.msn.com/bingame/hxic/default/Hexic2.swf`
  （98KB、Flash 6、stage 400x325）。
- `Hexic.xml`（語系字串）與 `sounds/` 必須跟 SWF 放同一個目錄，否則永遠停在 splash。

### 為什麼要 patch

MSN 版 SWF 是舊 `zone.msn.com/gameplayer` 外殼的*遊戲端模組*。splash 播完後它會
一直送 `fscommand("SessionReady", ...)`，等主機回：

```
GameClient.SetVariable("/EM:data0", xmlData);
GameClient.TCallLabel("/EM", "Init");
```

主機早就關站，所以遊戲永遠停在 splash、點什麼都沒反應——很容易誤判成「滑鼠事件
沒送到視窗」。

而且主機要傳的內容其實只有 `<data><game code="hxic"></game></data>`，
`InitSession()` 根本不讀它，所以整段握手可以直接拿掉。

### 改了哪三處

1. `frame_6/DoAction.as`——splash 的 `onEnterFrame` 內層，SessionReady 重試迴圈換成：

   ```actionscript
   this.onEnterFrame = null;
   _root._ReceivedSessionStart = true;
   _root.InitSession();
   _root.gotoAndStop("Menu");
   ```

   並把 `_loc1_.SessionUpdate(); fscommand("GetBackground");` 改成
   `_root.SessionUpdate();`

2. `frame_13/PlaceObject2_215_144`（Start Normal Mode）、`_215_136`
   （Start Timed Mode）——`fscommand("GameReady", ...)` 加條件式 `InitGame(true)`
   整段換成 `_loc1_.gotoAndStop("Active");`

3. `frame_108/PlaceObject2_296_135`（Confirm 的 Yes）——同上。

root timeline：frame 1 = `Active`（棋盤）、6 = `Splash`、13 = `Menu`
（`Fr = {Active:1, Splash:6, Menu:13}`）。進入 frame 1 時若 `_SplashPlayed` 存在，
會自動跑 `InitGame(true)`。

### 套用

```
./apply.sh Hexic2.orig.swf Hexic2.patched.swf /path/to/ffdec.jar
```

FFDec 取自 `jindrapetrik/jpexs-decompiler` releases 的 `ffdec_<ver>.zip`，需要 JRE。
注意 `-importScript` 的參數順序是**輸入檔、輸出檔、scripts 資料夾**，寫反會噴
`I/O error during reading`。

**只匯入改動的 4 個腳本。** 把整個匯出的 `scripts/` 目錄丟進去，會讓 FFDec 把 62 個
腳本全部重新編譯，位元組大範圍改變；實測會造成遊戲玩到一半卡死——主執行緒卡在 AVM1
無限迴圈、CPU 燒到約 60%、畫面不再重繪。

### 執行

```
HEXIC_DIR=~/Applications/Hexic ~/.local/bin/hexic
```

Ruffle 加 `--graphics vulkan`（`gl` 後帶有時連視窗都開不出來），並清空
`WAYLAND_DISPLAY`。沒套存檔 patch 時 `file://` 直開就行；套了之後必須走 `http://`（見下）。

### 存檔 patch（`patch/hexic-save`）

MSN 版完全不能存檔：把 62 個腳本全匯出，`SharedObject` 一次都沒出現。以前進度是送到
zone.msn.com 的 gameplayer 外殼（靠 `fscommand("SessionUpdate"/"GameEnd"/"GameBreak")`），
所以每次啟動都是第 1 關、0 分。

`patch/hexic-save` 在握手 patch 之上加了本機存檔，用 AVM1 的 SharedObject `hexic_save`：

| 腳本 | 作用 |
| --- | --- |
| `frame_6/DoAction.as` | splash：讀 `hexic_save` 到 `_root._SavedLevel` / `_SavedScore` |
| `frame_13/PlaceObject2_215_128` | Resume Game 按鈕：有存檔就啟用，`gotoAndStop("Active")` 前還原 `_InitialLevel` 與 `_Score` |
| `frame_146/DoAction.as`、`frame_153/DoAction.as` | 升級轉場 frame：寫入 `_Level` / `_Score` 並 `flush()` |

幾個坑：

- 升級動畫會經過 **`frame_146` 和 `frame_153` 兩個** frame。只改 `frame_153` 的話，
  永遠不會真的存檔。
- `createEmptyMovieClip()` 的深度必須在 AVM1 範圍內（-16383..16383）。寫 `98765`
  不會報錯但會被忽略，於是那一 frame 的分數還原根本沒跑；用 `16000`。
- LSO 會落在 `~/.local/share/ruffle/SharedObjects/127.0.0.1/<檔名>/hexic_save.sol`。
  資料夾是綁**檔名**的，SWF 改個名字就等於換一份空存檔。
- `file://` 不能用：Ruffle 會擋 SharedObject，錯誤是
  `SharedObject.get_local: Invalid path with .. segments`。要改用 HTTP 提供目錄——
  `bin/hexic` 就是這樣做（會自動找空的埠號）。
- 實測：存 `_Level=3 / _Score=5000`，續玩會回到第 4 關（HUD 顯示 `_Level + 1`）、
  分數正好 5000，放著不動也不會亂跳。但從很高的關卡（8 以上）續玩分數會失控暴增，
  那些關卡表本來就不預期這樣被進入，這種存檔當作免洗即可。

### 已知問題

- Ruffle 的 `Sound.getBytesLoaded()` 是 stub（回 0），音樂可能沒聲音。
- 視窗固定 400x325，要放大用 Ruffle 的 *View* 選單。
- 原生「Hexic Deluxe」（`HexicDeluxe.exe`）在 Wine 下是死路：它是原生外殼 +
  Flash ActiveX。序號可以驗過（`Key Valid`），但只會生出一個 113x2 的隱藏視窗；
  裝並註冊 `Flash.ocx`、改 virtual desktop、模擬 WinXP 全都無效。
