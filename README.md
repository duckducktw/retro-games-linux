# retro-games-linux

在 Linux 上跑 1995–2005 年的老 Windows／Flash 遊戲，走「原版執行檔」路線，不用重製版。

目前收錄：

| 遊戲 | 原版來源 | 執行方式 |
|---|---|---|
| 接龍 Solitaire (Win95) | Win95 OSR2 CAB 抽出的 `sol.exe` + `cards.dll` | Wine（Bottles `soda-9.0-1` runner，Win16 需要 lib32） |
| 新接龍 FreeCell (Win95) | 同上，`freecell.exe` | 同上（同一個 bottle，共用 `cards.dll`） |
| Hexic 旋轉泡泡球 (MSN 原版) | Flashpoint / Flash Museum 的 `Hexic2.swf` | Ruffle，SWF 已 patch 掉 MSN 主機握手 |

> 本 repo **不含**遊戲本體檔案（`*.exe` / `*.swf` / `*.dll` 都在 .gitignore）。只收啟動器、patch 與文件。

## 目錄

```
bin/         啟動器（複製到 ~/.local/bin 後 chmod +x）
desktop/     .desktop 檔（複製到 ~/.local/share/applications）
patch/       Hexic MSN 原版的 ActionScript patch 與套用腳本
docs/        各遊戲的取得與修復紀錄
```

## 接龍 / 新接龍（Wine + Bottles）

1. Bottles 需要 `soda-9.0-1` runner（內含 lib32）；host 套件版 wine 10 是純 wow64，跑不動 Win16 NE 執行檔。
2. 從 archive.org `win95hdd_202109` 抓 `WIN95_02.CAB`，用 `cabextract -F sol.exe -F cards.dll -F freecell.exe` 抽出。
3. 檔案放到 bottle 內 `C:\Solitaire\` 與 `C:\FreeCell\`，`cards.dll` 另放一份到 `C:\windows\system32\`。
4. `bottle.yml` 的 `Arch:` 要改成 `win64`，不然每次啟動都會因為 `WINEARCH` 衝突直接中止。

## Hexic（Ruffle）

見 `docs/hexic-msn-patch.md`。重點：MSN 版 SWF 開頭會一直等 `zone.msn.com` 主機回握手訊號，主機早就沒了 → patch 掉握手直接進主選單。
