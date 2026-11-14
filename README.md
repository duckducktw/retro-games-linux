# retro-games-linux

[English](#english) | [繁體中文](#繁體中文)

Running late-90s / early-2000s Windows and Flash games on Linux — using the
**original binaries**, not remakes.

| Game | Original source | Runtime |
|---|---|---|
| Solitaire (Win95) | `sol.exe` + `cards.dll` extracted from Win95 OSR2 CABs | Wine (Bottles `soda-9.0-1` runner, Win16 needs lib32) |
| FreeCell (Win95) | `freecell.exe` from the same CABs | Same bottle, shares `cards.dll` |
| Hexic (MSN original) | `Hexic2.swf` from Flashpoint / Flash Museum | Ruffle, SWF patched to drop the dead MSN host handshake |

> This repo contains **no game data**. `*.exe` / `*.swf` / `*.dll` / `*.CAB` are
> git-ignored; only launchers, patches and docs live here.

## English

### Layout

```
bin/         launchers (copy to ~/.local/bin, chmod +x)
desktop/     .desktop entries (copy to ~/.local/share/applications)
patch/       ActionScript patch + apply script for the MSN Hexic SWF
docs/        acquisition / repair notes per game
```

### Requirements

- **Wine via Bottles** (flatpak `com.usebottles.bottles`) with the `soda-9.0-1`
  runner — the distro `wine` 10 package is pure wow64 and cannot run Win16 NE
  executables at all.
- **Ruffle** desktop build (nightly tarball from GitHub) for Flash content.
- **FFDec** (`jpexs-decompiler`) + a JRE, only needed to rebuild the Hexic patch.
- `xdotool` (window raise/activate in the Hexic launcher), `cabextract` for CABs.

### Solitaire / FreeCell (Wine + Bottles)

1. Create a bottle with the `soda-9.0-1` runner, then edit its `bottle.yml` and
   set `Arch: win64`. Leaving `win32` there makes every launch abort with
   `WINEARCH set to win32 but ... is a 64-bit installation` (silent, exit 0).
2. Grab `WIN95_02.CAB` from archive.org item `win95hdd_202109` and extract:
   `cabextract -F sol.exe -F freecell.exe -F cards.dll -d out WIN95_02.CAB`.
3. Copy the files into the bottle as `C:\Solitaire\SOL.EXE`,
   `C:\FreeCell\FREECELL.EXE`, plus `cards.dll` next to each game **and** into
   `C:\windows\system32\` — without `cards.dll` you get missing card faces.
4. Install the launchers: `cp bin/solitaire bin/freecell ~/.local/bin/ && chmod +x ~/.local/bin/{solitaire,freecell}`.

### Hexic (Ruffle)

See [`docs/hexic-msn-patch.md`](docs/hexic-msn-patch.md). Short version: the MSN
SWF waits forever for `fscommand("ClientReady")` / `SessionReady` to be answered
by the (long dead) `zone.msn.com` host, so it never leaves the splash screen.
The patch removes the handshake and jumps straight to the main menu.

### Notes and gotchas

- Screenshotting XWayland windows with `xwd` fails; use python-xlib
  `get_image()` or `spectacle` instead. On a composited desktop, a fullscreen
  app in front makes `root.get_image()` fail with `BadMatch`.
- Never `pkill -f "Ruffle/ruffle"` from a shell whose own command line contains
  that string — it kills the shell. Use `pgrep -x ruffle`.
- Ruffle needs `--graphics vulkan` on some GPUs; `--graphics gl` may open no
  window at all. Clearing `WAYLAND_DISPLAY` avoids a second failed surface path.
- `file://` loading works for this SWF; no local HTTP server is needed.

### License

MIT — see [LICENSE](LICENSE). Game data remains the property of its respective
owners and is not distributed here.

## 繁體中文

在 Linux 上跑 1990 末／2000 初的 Windows 與 Flash 遊戲，走**原版執行檔**路線，不用重製版。

| 遊戲 | 原版來源 | 執行方式 |
|---|---|---|
| 接龍 (Win95) | Win95 OSR2 CAB 抽出的 `sol.exe` + `cards.dll` | Wine（Bottles `soda-9.0-1` runner，Win16 需要 lib32） |
| 新接龍 (Win95) | 同一組 CAB 的 `freecell.exe` | 同一個 bottle，共用 `cards.dll` |
| Hexic 旋轉泡泡球 (MSN 原版) | Flashpoint / Flash Museum 的 `Hexic2.swf` | Ruffle，SWF 已 patch 掉失效的 MSN 主機握手 |

> 本 repo **不含遊戲本體**。`*.exe` / `*.swf` / `*.dll` / `*.CAB` 都在 `.gitignore`，
> 只收啟動器、patch 與文件。

### 目錄

```
bin/         啟動器（複製到 ~/.local/bin 後 chmod +x）
desktop/     .desktop 檔（複製到 ~/.local/share/applications）
patch/       Hexic MSN 原版的 ActionScript patch 與套用腳本
docs/        各遊戲的取得與修復紀錄
```

### 需求

- **Wine（透過 Bottles，flatpak `com.usebottles.bottles`）**，且要用 `soda-9.0-1`
  runner——發行版套件的 wine 10 是純 wow64，**完全跑不動 Win16 NE 執行檔**。
- **Ruffle** 桌面版（GitHub nightly tarball）用來跑 Flash 內容。
- **FFDec**（`jpexs-decompiler`）＋ JRE，只有要重新產生 Hexic patch 時才需要。
- `xdotool`（Hexic 啟動器叫回視窗用）、`cabextract`（解 CAB）。

### 接龍 / 新接龍

1. 用 `soda-9.0-1` runner 建 bottle，然後改 `bottle.yml` 把 `Arch:` 設成 `win64`。
   留著 `win32` 會讓每次啟動都以 `WINEARCH set to win32 but ... is a 64-bit
   installation` 無聲中止（exit 0、沒有視窗）。
2. 從 archive.org `win95hdd_202109` 抓 `WIN95_02.CAB`，抽出檔案：
   `cabextract -F sol.exe -F freecell.exe -F cards.dll -d out WIN95_02.CAB`。
3. 放進 bottle：`C:\Solitaire\SOL.EXE`、`C:\FreeCell\FREECELL.EXE`，`cards.dll`
   放在各遊戲旁**並且**再放一份到 `C:\windows\system32\`（少了它會缺牌面）。
4. 安裝啟動器：`cp bin/solitaire bin/freecell ~/.local/bin/ && chmod +x ~/.local/bin/{solitaire,freecell}`。

### Hexic（Ruffle）

詳見 [`docs/hexic-msn-patch.md`](docs/hexic-msn-patch.md)。簡短版：MSN 版 SWF 開頭
會一直送 `fscommand("ClientReady")` / `SessionReady`，等早就關站的 `zone.msn.com`
主機回握手訊號，所以永遠停在 splash。patch 把握手整段拿掉，直接進主選單。

### 注意事項

- XWayland 視窗用 `xwd` 抓圖會失敗，改用 python-xlib `get_image()` 或 `spectacle`。
  桌面上有全螢幕程式蓋著時，`root.get_image()` 會噴 `BadMatch`。
- 不要在指令列含同樣字串的 shell 裡跑 `pkill -f "Ruffle/ruffle"`，會把自己殺掉；
  用 `pgrep -x ruffle`。
- 部分顯卡要 `--graphics vulkan`，`--graphics gl` 可能連視窗都開不出來；清空
  `WAYLAND_DISPLAY` 可避開另一條失敗的 surface 路徑。
- 這個 SWF 用 `file://` 直開就行，不需要本機 HTTP server。

### 授權

MIT，見 [LICENSE](LICENSE)。遊戲本體版權屬各自權利人，本 repo 不散布。
