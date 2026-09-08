#!/usr/bin/env bash
# ONEBOOK ELD mobil — taqiqlar grepi (tz-mobile §2 "Lint va TAQIQLAR").
# CI da ishlaydi: chiqish kodi 0 = toza, 1 = kamida bitta buzilish.
# Ishlatish: bash tool/check_forbidden.sh   (mobile/ ildizidan)
set -uo pipefail

cd "$(dirname "$0")/.." || exit 2

FAIL=0
RED=$'\033[0;31m'; GRN=$'\033[0;32m'; YEL=$'\033[0;33m'; OFF=$'\033[0m'

report() { # <sarlavha> <natija-fayl>
  if [ -s "$2" ]; then
    printf '%sFAIL%s  %s\n' "$RED" "$OFF" "$1"
    sed 's/^/        /' "$2"
    FAIL=1
  else
    printf '%sOK%s    %s\n' "$GRN" "$OFF" "$1"
  fi
  rm -f "$2"
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Generatsiya qilingan va test kodini chetlab o'tish uchun umumiy istisnolar.
EXCL_GEN=(--exclude-dir=.dart_tool --exclude-dir=build --exclude-dir=.git
          --exclude=*.g.dart --exclude=*.freezed.dart --exclude=*.mocks.dart)

# Skanerlanadigan ishlab chiqarish kodi: ilova lib/ + har paketning lib/ si.
# Paketlarning test/ va tool/ papkalari taqiqlarga bo'ysunmaydi (ular atayin
# taqiqlangan naqshlarni matn sifatida qidiradi).
SRC_DIRS=(lib)
for d in packages/*/lib; do [ -d "$d" ] && SRC_DIRS+=("$d"); done

# Izoh qatorlarini (`//`, `///`, `*`) natijadan chiqaradi.
strip_comments() { grep -v -E '^[^:]+:[0-9]+: *(///?|\*)' || true; }

# ---------------------------------------------------------------- 1. DateTime.now()
# Domen, sof Dart paketlari va HOS/sync mantiqida vaqt faqat TimeSource orqali.
DT_DIRS=()
for d in packages/hos_engine/lib packages/sync_core/lib lib/core/time lib/core/sync; do
  [ -d "$d" ] && DT_DIRS+=("$d")
done
while IFS= read -r d; do DT_DIRS+=("$d"); done < <(find lib/features -type d -name domain 2>/dev/null)
if [ ${#DT_DIRS[@]} -gt 0 ]; then
  grep -rn "${EXCL_GEN[@]}" --include='*.dart' 'DateTime\.now()' "${DT_DIRS[@]}" 2>/dev/null \
    | grep -v 'ignore: eld_time_source' | strip_comments > "$TMP/dt"
fi
report "DateTime.now() domen/paketlarda yo'q (TimeSource majburiy)" "$TMP/dt"

# ---------------------------------------------------------------- 2. print / debugPrint
grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E '(^|[^A-Za-z0-9_.])(print|debugPrint)\(' \
  "${SRC_DIRS[@]}" 2>/dev/null | grep -v '/eld_api/' | strip_comments > "$TMP/pr"
report "print()/debugPrint() prod kodida yo'q (PII sizishi)" "$TMP/pr"

# ---------------------------------------------------------------- 3. Hard-coded rang
# Ranglar faqat lib/core/ui/tokens.dart da. Color(0x..), Colors.<name>, Color.fromARGB.
grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E 'Color\(0x|Color\.fromARGB\(|Color\.fromRGBO\(|\bColors\.[a-z]' \
  "${SRC_DIRS[@]}" 2>/dev/null \
  | grep -v '^lib/core/ui/tokens.dart' \
  | grep -v '/eld_api/' | strip_comments > "$TMP/col"
report "Hard-coded rang faqat core/ui/tokens.dart da" "$TMP/col"

# ---------------------------------------------------------------- 4. http paketi
{
  grep -rn --include='pubspec.yaml' -E '^\s*http:\s' . 2>/dev/null \
    | grep -v '/build/' | grep -v '\.dart_tool'
  grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E "import\s+'package:http/" "${SRC_DIRS[@]}" 2>/dev/null
  grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E "import\s+'dart:io'" lib 2>/dev/null \
    | grep -i 'httpclient'
} > "$TMP/http"
report "\`http\` paketi ishlatilmagan (yagona transport — dio)" "$TMP/http"

# ---------------------------------------------------------------- 5. Hard-coded matn (evristika)
# Widget qurilishida uchraydigan matn konstruktorlari: Text('...'), label: '...' va h.k.
# Faqat lib/features/**/presentation va lib/core/ui da tekshiriladi.
UI_DIRS=()
[ -d lib/core/ui ] && UI_DIRS+=(lib/core/ui)
while IFS= read -r d; do UI_DIRS+=("$d"); done < <(find lib/features -type d -name presentation 2>/dev/null)
if [ ${#UI_DIRS[@]} -gt 0 ]; then
  grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E \
    "(Text\(\s*'[^']{2,}'|(label|labelText|hintText|title|tooltip|semanticsLabel|helperText|errorText)\s*:\s*'[^']{2,}')" \
    "${UI_DIRS[@]}" 2>/dev/null \
    | grep -v "// i18n-exempt" \
    | grep -v "_debug" | strip_comments > "$TMP/txt"
fi
report "Widget ichida hard-coded matn yo'q (context.l10n majburiy)" "$TMP/txt"

# ---------------------------------------------------------------- 6. eld_api modeli presentation da
{
  while IFS= read -r d; do
    grep -rn --include='*.dart' -E "import\s+'package:eld_api/" "$d" 2>/dev/null
  done < <(find lib/features -type d -name presentation 2>/dev/null)
  [ -d lib/core/ui ] && grep -rn --include='*.dart' -E "import\s+'package:eld_api/" lib/core/ui 2>/dev/null
} > "$TMP/api"
report "M5: eld_api modeli presentation qatlamiga chiqmagan" "$TMP/api"

# ---------------------------------------------------------------- 7. company_id so'rov tanasida (M164)
grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E "'company_id'\s*:" lib 2>/dev/null \
  | strip_comments > "$TMP/cid"
report "M164: company_id so'rov tanasiga qo'yilmagan" "$TMP/cid"

# ---------------------------------------------------------------- 8. Random() (xavfsizlik)
grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E '(^|[^.a-zA-Z_])Random\(\)' "${SRC_DIRS[@]}" 2>/dev/null \
  | strip_comments > "$TMP/rnd"
report "Random.secure() ishlatilgan (oddiy Random() taqiq)" "$TMP/rnd"

# ---------------------------------------------------------------- 9. sof Dart paketlarida flutter
for p in packages/hos_engine packages/sync_core; do
  [ -d "$p" ] || continue
  grep -n -E '^\s*flutter\s*:' "$p/pubspec.yaml" 2>/dev/null | sed "s|^|$p/pubspec.yaml:|"
done > "$TMP/fl"
report "M4: hos_engine / sync_core da flutter bog'liqligi yo'q" "$TMP/fl"

# --------------------------------------------------------------- 10. eld_api o'z Dio si bilan (S-M7)
# `EldApi()` parametrsiz chaqirilsa generatsiya qilingan paket o'z `Dio` ini
# nisbiy `baseUrl='/api/v1'` bilan quradi: auth, PII maskalash, idempotentlik va
# pinning interceptorlari qo'llanmaydi. Yagona ruxsat — `EldApi(dio: ...)`.
{
  grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E '\bEldApi\(' "${SRC_DIRS[@]}" 2>/dev/null \
    | grep -v '/eld_api/' | grep -v 'dio:' | strip_comments
  # `basePathOverride` — o'z klientini qurishning ikkinchi yo'li.
  grep -rn "${EXCL_GEN[@]}" --include='*.dart' -E 'basePathOverride\s*:' "${SRC_DIRS[@]}" 2>/dev/null \
    | grep -v '/eld_api/' | strip_comments
} > "$TMP/eldapi"
report "S-M7: eld_api faqat tashqi Dio in'ektsiyasi bilan (EldApi(dio: ...))" "$TMP/eldapi"

# --------------------------------------------------------------- 11. copyWith(fontWeight:) (D-26/D-28)
# Plus Jakarta Sans — **variable** shrift (`wght` o'qi). `copyWith(fontWeight:)`
# yolg'iz o'zi o'qni yangilamaydi: Flutter og'irlikni interpolatsiya qilmaydi va
# matn baribir Regular chiziladi. Yagona to'g'ri yo'l — `TextStyle.withWeight()`
# (u `fontWeight` va `fontVariations` ni birga beradi).
# Ko'p qatorli `copyWith( ... )` chaqiruvlari ham qamrab olinadi.
{
  FW_FILES=()
  while IFS= read -r f; do FW_FILES+=("$f"); done < <(
    find "${SRC_DIRS[@]}" -name '*.dart' \
      ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.mocks.dart' 2>/dev/null \
      | grep -v '/eld_api/'
  )
  [ ${#FW_FILES[@]} -gt 0 ] && perl -0777 -ne '
    # Izohlarni o\x27rniga bo\x27sh joy qo\x27yib olib tashlaymiz (qator raqami saqlanadi).
    s{//[^\n]*}{}g;
    while (/copyWith\s*\((?:[^()]|\([^()]*\))*\)/gs) {
      my $m = $&;
      next unless $m =~ /fontWeight\s*:/;
      next if $m =~ /fontVariations\s*:/;
      my $line = 1 + (substr($_, 0, pos($_) - length($m)) =~ tr/\n//);
      my $head = (split /\n/, $m)[0];
      print "$ARGV:$line: $head\n";
    }
  ' "${FW_FILES[@]}" 2>/dev/null
} > "$TMP/fw"
report "Variable shrift: copyWith(fontWeight:) o'rniga withWeight() ishlatilgan" "$TMP/fw"

echo
if [ "$FAIL" -ne 0 ]; then
  printf '%sTaqiqlar grepi YIQILDI.%s\n' "$RED" "$OFF"
  exit 1
fi
printf '%sTaqiqlar grepi toza.%s\n' "$GRN" "$OFF"
[ -d packages/hos_engine ] || printf '%snote%s  packages/hos_engine hali yo'"'"'q — 1-tekshiruv qisman.\n' "$YEL" "$OFF"
exit 0
