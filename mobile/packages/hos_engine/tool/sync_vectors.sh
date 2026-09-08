#!/usr/bin/env bash
# M45/M174 — golden vektor faylini backenddan olib keladi va SHA-256 qulfini
# yangilaydi. Fayl `packages/` ichida MANBA emas: yagona haqiqat manbai
# `backend/internal/hos/testdata/hos-test-vectors.json`. Bu skript faqat CI da
# backend repo mavjud bo'lmagan holat uchun nusxa tayyorlaydi.
#
# Ishlatish:
#   tool/sync_vectors.sh            # nusxa oladi, hash mos kelishini tekshiradi
#   tool/sync_vectors.sh --update   # hash qulfini QAYTA yozadi (faqat CR bilan!)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pkg="$(dirname "$here")"
src="${HOS_VECTORS_SRC:-$pkg/../../../backend/internal/hos/testdata/hos-test-vectors.json}"
dst="$pkg/test/testdata/hos-test-vectors.json"
lock="$pkg/test/testdata/hos-test-vectors.sha256"

if [[ ! -f "$src" ]]; then
  echo "hos-test-vectors.json topilmadi: $src" >&2
  exit 1
fi

sum="$(shasum -a 256 "$src" | awk '{print $1}')"

if [[ "${1:-}" == "--update" ]]; then
  cp "$src" "$dst"
  printf '%s\n' "$sum" > "$lock"
  echo "yangilandi: $sum"
  exit 0
fi

if [[ -f "$lock" ]] && [[ "$sum" != "$(cat "$lock")" ]]; then
  echo "STOP: hos-test-vectors.json hash mos kelmadi." >&2
  echo "  kutilgan: $(cat "$lock")" >&2
  echo "  topilgan: $sum" >&2
  echo "Format ikkala tomonning kontrakti — o'zgarishi CR talab qiladi (M174)." >&2
  exit 1
fi

cp "$src" "$dst"
printf '%s\n' "$sum" > "$lock"
echo "sinxron: $sum"
