#!/usr/bin/env bash
# lib/l10n/parts/*.arb bo'laklarini lib/l10n/app_en.arb ga birlashtiradi va gen-l10n ni yurgizadi.
# Har agent FAQAT o'z bo'lagini tahrirlaydi — app_en.arb generatsiya natijasi, qo'lda tahrirlanmaydi.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, glob, os, collections
out = collections.OrderedDict()
out["@@locale"] = "en"
dupes = []
for p in sorted(glob.glob("lib/l10n/parts/*.arb")):
    d = json.load(open(p, encoding="utf-8"))
    for k, v in d.items():
        if k == "@@locale":
            continue
        if k in out and not k.startswith("@"):
            dupes.append(f"{k} ({os.path.basename(p)})")
        out[k] = v
json.dump(out, open("lib/l10n/app_en.arb", "w", encoding="utf-8"),
          ensure_ascii=False, indent=2)
print(f"birlashtirildi: {len(glob.glob('lib/l10n/parts/*.arb'))} bo'lak → "
      f"{len([k for k in out if not k.startswith('@')])} kalit")
if dupes:
    print("DUBLIKAT KALITLAR:", ", ".join(dupes))
    raise SystemExit(1)
PY
flutter gen-l10n >/dev/null
echo "gen-l10n OK"

# #B-138: generator formatlanmagan kod chiqaradi — CI `format` job'i shundan
# qizarardi. Generatsiyadan keyin darhol formatlanadi (loyiha bo'yicha 100).
dart format --line-length=100 lib/l10n/generated >/dev/null
echo "format OK"
