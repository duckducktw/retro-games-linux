#!/usr/bin/env bash
# 把 patch/hexic-msn/scripts 內的 ActionScript 蓋回原始 Hexic2.swf
# 用法：./apply.sh <原始 Hexic2.swf> <輸出檔> [ffdec.jar]
set -eu
IN="${1:?原始 SWF}"
OUT="${2:?輸出 SWF}"
FFDEC="${3:-ffdec.jar}"
DIR="$(cd "$(dirname "$0")" && pwd)/scripts"

# 參數順序是 in, out, scriptdir（順序寫錯會噴 I/O error during reading）
java -jar "$FFDEC" -importScript "$IN" "$OUT" "$DIR"

echo "已輸出 $OUT"
echo "驗證："
java -jar "$FFDEC" -export script /tmp/verify_out "$OUT" >/dev/null
grep -c "InitSession" /tmp/verify_out/scripts/frame_6/DoAction.as || true
