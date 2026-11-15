#!/usr/bin/env bash
# 把 patch/hexic-save/scripts 蓋回「已解除 MSN 握手」的 Hexic2.swf，
# 得到可存檔／讀檔的版本。
# 用法：./apply.sh <已握手 patch 的 Hexic2.swf> <輸出檔> [ffdec.jar]
set -eu
IN="${1:?輸入 SWF（需先套用 patch/hexic-msn）}"
OUT="${2:?輸出 SWF}"
FFDEC="${3:-ffdec.jar}"
DIR="$(cd "$(dirname "$0")" && pwd)/scripts"

# 參數順序固定為 in, out, scriptdir
java -jar "$FFDEC" -importScript "$IN" "$OUT" "$DIR"

echo "已輸出 $OUT"
echo "驗證（重新匯出後檢查關鍵字）："
VER="$(mktemp -d)"
java -jar "$FFDEC" -export script "$VER" "$OUT" >/dev/null
grep -l "hexic_save" "$VER"/scripts/frame_6/DoAction.as "$VER"/scripts/frame_146/DoAction.as "$VER"/scripts/frame_153/DoAction.as
grep -c "_SavedLevel" "$VER/scripts/frame_13/PlaceObject2_215_128/CLIPACTIONRECORD onClipEvent(load).as"
