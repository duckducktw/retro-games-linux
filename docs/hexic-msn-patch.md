# MSN 原版 Hexic（Hexic2.swf）patch 紀錄

## 來源
- Flashpoint game id：`c494046c-66e2-4ef8-a760-a3838f837b80`
- zip：`https://games.flashmuseum.net/c494046c-66e2-4ef8-a760-a3838f837b80.zip`
  （直連 curl 會失敗，要在 flashmuseum.net 頁面用 browser `fetch(..., {credentials:'include'})` 下載）
- SWF：`content/zone.msn.com/bingame/hxic/default/Hexic2.swf`（98KB、Flash 6、stage 400x325）
- 同目錄需要 `Hexic.xml`（語系字串）與 `sounds/`（音效），否則卡在 splash

## 為什麼要 patch
MSN 版 SWF 是給 `zone.msn.com/gameplayer` 外殼用的。splash 播完後它只會一直送
`fscommand("SessionReady")`，等主機回：

```
GameClient.SetVariable("/EM:data0", xmlData);
GameClient.TCallLabel("/EM", "Init");
```

主機早就沒了 → 永遠停在 splash，點任何按鈕都沒反應（很容易誤判成滑鼠事件沒送到）。

而 `data0` 內容只是 `<data><game code="hxic"></game></data>`，SWF 的 `InitSession()`
根本不讀它 → 握手整段可以直接拿掉。

## 改了哪三處
1. `frame_6/DoAction.as`（splash 的 onEnterFrame 內層）：把 SessionReady 迴圈換成
   ```actionscript
   this.onEnterFrame = null;
   _root._ReceivedSessionStart = true;
   _root.InitSession();
   _root.gotoAndStop("Menu");
   ```
   並把 `_loc1_.SessionUpdate(); fscommand("GetBackground");` 改成 `_root.SessionUpdate();`
2. `frame_13/PlaceObject2_215_144`（Start Normal Mode）、`_215_136`（Start Timed Mode）：
   `fscommand("GameReady", …)` + 條件式 `InitGame(true)` → `_loc1_.gotoAndStop("Active");`
3. `frame_108/PlaceObject2_296_135`（Confirm 的 Yes）：同上

root timeline：frame 1 = Active（棋盤）、6 = Splash、13 = Menu；進入 frame 1 時若
`_SplashPlayed` 存在會自動 `InitGame(true)`。

## 套用
```
./apply.sh Hexic2.orig.swf Hexic2.patched.swf /path/to/ffdec.jar
```
FFDec：`jindrapetrik/jpexs-decompiler` releases 的 `ffdec_<ver>.zip`，需要 java。

**只匯入改動的 4 個腳本**（不要整個 `scripts/` 目錄全丟進去）。全量匯入會讓 62 個腳本
全部重新編譯，位元組大面積改變，實測會引發遊戲中途 AVM1 無限迴圈（畫面凍結、CPU 燒高）。

## 執行
```
HEXIC_DIR=~/Applications/Hexic ~/.local/bin/hexic
```
Ruffle 用 `--graphics vulkan`（`gl` 有時不出視窗），並清空 `WAYLAND_DISPLAY`；
`file://` 直開即可，不需要本機 HTTP server。

## 已知現象
- Ruffle 的 `Sound.getBytesLoaded()` 是 stub（回 0），音樂可能不出聲
- 視窗固定 400x325，要放大用 Ruffle 的 View 選單
- 原本的 Hexic Deluxe 原生版（`HexicDeluxe.exe`）在 wine 沒救：它是原生外殼 + Flash
  ActiveX，序號可以通過但只會生出 113x2 的隱藏視窗（裝 `Flash.ocx`、`regsvr32`、
  virtual desktop 全試過無效）
