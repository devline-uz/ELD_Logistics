#!/usr/bin/env python3
"""docs/api/permissions.md ni admin/openapi/swagger.json dan qayta yaratadi.

Ishlatish:  python3 scripts/gen-permissions-doc.py
Oldin:      cd admin && npm run api     (swagger.json ni yangilaydi)
"""
import collections
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
SPEC = ROOT / "admin" / "openapi" / "swagger.json"
OUT = ROOT / "docs" / "api" / "permissions.md"
METHODS = ("get", "post", "put", "patch", "delete")
SPECIAL = {
    "public": "auth'siz ochiq (login, parol tiklash, invitation)",
    "authenticated": "har qanday tizimga kirgan foydalanuvchi, permission tekshirilmaydi",
    "super_admin": "alohida bayroq, rol emas (F33) — `/companies*` CRUD",
}
OR_GUARDED = [
    ("GET /unidentified-events", "logs.assign_unidentified", "logs.assign_unidentified", "logs.read"),
    ("GET /permissions", "permissions.read", "permissions.read", "roles.read"),
]

spec = json.loads(SPEC.read_text(encoding="utf-8"))
by_key = collections.defaultdict(list)
missing = []
for path, ops in spec["paths"].items():
    for method, op in ops.items():
        if method not in METHODS:
            continue
        perm = op.get("x-permission")
        if not perm:
            missing.append(f"{method.upper()} {path}")
            continue
        by_key[perm].append((method.upper(), path))

if missing:
    raise SystemExit("x-permission yo'q operatsiyalar:\n  " + "\n  ".join(missing))

real = sorted(k for k in by_key if k not in SPECIAL)
groups = collections.defaultdict(list)
for key in real:
    groups[key.split(".")[0]].append(key)

L = [
    "# Permission katalogi (GENERATSIYA)\n",
    "Manba: `admin/openapi/swagger.json` → har operatsiyaning `x-permission` maydoni.",
    "Qayta yaratish: `npm run api` dan keyin `python3 scripts/gen-permissions-doc.py`.\n",
    f"**{len(real)} ta haqiqiy permission kaliti**, {len(groups)} guruh. "
    "Uchta maxsus qiymat permission emas:\n",
    "| Maxsus qiymat | Operatsiya | Ma'no |",
    "|---|---|---|",
]
L += [f"| `{k}` | {len(by_key[k])} | {v} |" for k, v in SPECIAL.items()]
L += [
    "\n> ⚠️ TZ §4.1 «105 kalit» deydi — **noto'g'ri**. Backend yakuniy tozalashda 4 ta o'lik kalitni",
    "> olib tashladi (`tracking.read`, `tracking.history`, `trips.read`, `support.update`) va",
    "> `drivers.license.view` ni qo'shdi. **Haqiqiy son — 104.** Katalogdagi 104 kalitning",
    "> hammasi ishlatiladi (ishlatilmagan 0, yetishmayotgan 0).\n",
    "## OR mantiq bilan qo'riqlangan endpointlar (CI testida ISTISNO)\n",
    "swaggo OR sintaksisiga ega emas — Swagger faqat bitta kalit ko'rsatadi, "
    "backend esa ikkitasini qabul qiladi:\n",
    "| Endpoint | Swagger'da | Haqiqatda |",
    "|---|---|---|",
]
L += [f"| `{ep}` | `{shown}` | `{a}` **yoki** `{b}` |" for ep, shown, a, b in OR_GUARDED]

L.append("\n## Kalitlar guruh bo'yicha\n")
for group in sorted(groups):
    L += [f"### `{group}.*` ({len(groups[group])})\n", "| Kalit | Metod | Endpoint |", "|---|---|---|"]
    for key in groups[group]:
        for i, (method, path) in enumerate(sorted(by_key[key])):
            L.append(f"| {'`' + key + '`' if i == 0 else ''} | {method} | `{path}` |")
    L.append("")

L.append("## Maxsus qiymatli operatsiyalar\n")
for key in SPECIAL:
    L.append(f"### `{key}`\n")
    L += [f"- `{method} {path}`" for method, path in sorted(by_key[key])]
    L.append("")

OUT.write_text("\n".join(L), encoding="utf-8")
print(f"{OUT.relative_to(ROOT)}: {len(real)} kalit, {len(groups)} guruh")
