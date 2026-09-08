#!/usr/bin/env bash
# ONEBOOK ELD mobil — packages/eld_api generatsiyasi (M1 [MUST]).
# Manba: ../contracts/swagger.json (Swagger 2.0, basePath /api/v1) — YAGONA kontrakt manbai.
# Chiqish: packages/eld_api (linguist-generated; QO'LDA TAHRIRLANMAYDI).
#
# Ishlatish:
#   bash tool/generate_api.sh          # generatsiya
#   bash tool/generate_api.sh --check  # CI: generatsiya + git diff bo'sh bo'lishi shart
set -euo pipefail

cd "$(dirname "$0")/.." || exit 2
ROOT="$(pwd)"
SPEC="$ROOT/../contracts/swagger.json"
OUT="$ROOT/packages/eld_api"
LOG="$ROOT/.dart_tool/openapi-generator.log"

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

if [ ! -f "$SPEC" ]; then
  echo "XATO: kontrakt topilmadi: $SPEC" >&2
  exit 2
fi

if ! command -v openapi-generator >/dev/null 2>&1; then
  cat >&2 <<'MSG'
XATO: `openapi-generator` topilmadi.

O'rnatish (macOS):      brew install openapi-generator
O'rnatish (Linux/CI):   npm install -g @openapitools/openapi-generator-cli
Talab:                  Java 11+ (openapi-generator JVM ustida ishlaydi)

Generatsiya qilinmadi. packages/eld_api o'zgarmadi.
MSG
  exit 3
fi

mkdir -p "$(dirname "$LOG")"
echo "openapi-generator: $(openapi-generator version 2>/dev/null || echo '?')"
echo "spec: $SPEC"
echo "out:  $OUT"

# dart-dio: dio + built_value asosidagi tipli klient.
# Eslatma: generator butun paketni qayta yozadi — qo'lda o'zgartirish yo'qoladi.
rm -rf "$OUT"
openapi-generator generate \
  --input-spec "$SPEC" \
  --generator-name dart-dio \
  --output "$OUT" \
  --additional-properties=pubName=eld_api,\
pubDescription="ONEBOOK ELD API klienti — GENERATSIYA, qo'lda tahrirlanmaydi",\
pubVersion=1.0.0,\
serializationLibrary=built_value,\
nullableFields=true,\
enumUnknownDefaultCase=true \
  --global-property=apiDocs=false,modelDocs=false,apiTests=false,modelTests=false \
  --skip-validate-spec \
  >"$LOG" 2>&1 || { echo "XATO: generatsiya yiqildi, log: $LOG" >&2; tail -30 "$LOG" >&2; exit 4; }

echo "generatsiya OK (log: $LOG)"

# built_value serializerlari uchun build_runner generatsiyaga muhtoj.
if command -v dart >/dev/null 2>&1; then
  (cd "$OUT" && dart pub get >>"$LOG" 2>&1 &&
    dart run build_runner build --delete-conflicting-outputs >>"$LOG" 2>&1) ||
    { echo "XATO: eld_api build_runner yiqildi, log: $LOG" >&2; exit 5; }
  echo "build_runner OK"
fi

if [ "$CHECK" -eq 1 ]; then
  if [ -n "$(git -C "$ROOT/.." status --porcelain -- mobile/packages/eld_api 2>/dev/null)" ]; then
    echo "XATO: packages/eld_api git diff bo'sh emas — kontrakt bilan sinxron emas." >&2
    git -C "$ROOT/.." --no-pager diff --stat -- mobile/packages/eld_api >&2 || true
    exit 6
  fi
  echo "diff bo'sh — kontrakt sinxron."
fi
