# ONEBOOK ELD — loyiha yo'riqnomasi

**Manba talab:** `tz.md` (v2.2) — backend · `tz-mobile.md` — mobil · `tz-admin-frontend.md` — admin panel.
Kod TZ dan chetlashsa — avval TZ o'zgartiriladi (CR), keyin kod.
**Joriy bosqich:** **mobil ilova** (Flutter, `mobile/`). Backend `v1` tugagan va muzlatilgan.

## Papkalar
- `backend/` — butun backend kodi (boshqa joyga backend kodi yozilmaydi) · reja: `tasks.md`
- `mobile/` — butun Flutter kodi · reja: `mobile/tasks.md` · dizayn manbai: `mobile/design/figma/`
- `contracts/` — muzlatilgan backend kontrakti (`swagger.json`, `permissions.md`, `websocket.md`) — klientlar uchun yagona haqiqat manbai
- `.claude/agents/` — loyiha subagentlari
- `.claude/skills/` — siqilgan TZ bilimi (butun tz.md ni qayta o'qimaslik uchun)

## tz.md xaritasi (kerakli qismni sed bilan o'qi, butun faylni emas)
| Qatorlar | Mazmun |
|---|---|
| 60–136 | Obyektlar modeli, region profili |
| 137–205 | Duty status, HOS qoidalari |
| 206–300 | Daily log, sertifikatsiya, DVIR, maintenance, co-driver, ELD, unidentified |
| 300–360 | Violations, tracking, hisobotlar, chat, rollar/permissionlar |
| 360–450 | Audit, validatsiya qoidalari, bildirishnomalar, dashboard |
| 452–620 | Arxitektura: offline, xavfsizlik, scalability, Go stack, Swagger |
| 620–730 | Storage/retention, backup, monitoring, test, CI/CD, session, NFR |
| 765–895 | **DB sxemasi (to'liq)** |
| 897–955 | **Sync protokoli + API endpoint ro'yxati** |
| 956–1031 | Timeline, risklar, acceptance criteria / DoD |

## Subagentlar (`.claude/agents/`)
**Backend (Go):** `eld-go-architect` · `eld-db-engineer` · `eld-api-developer` · `eld-hos-engineer` ·
`eld-sync-engineer` · `eld-security-auditor` · `eld-test-engineer` · `eld-code-reviewer`

**Mobil (Flutter):** `flutter-architect` · `figma-extractor` · `screen-implementer` · `hos-dart-porter` ·
`offline-sync-engineer` · `ble-integration` · `flutter-test-engineer` ·
`mobile-security-auditor` · `flutter-code-reviewer` · `release-engineer`

Ish **subagentlar orqali** bajariladi. Har agent o'z skillarini o'qib boshlaydi.
Parallel agentlar faqat kesishmaydigan papkalarda ishlaydi.

## Skillar (`.claude/skills/`)
**Backend:** `eld-go-conventions` · `eld-swagger` · `eld-db` · `eld-hos` · `eld-sync` ·
`eld-api-contract` · `eld-security`
**Mobil:** `flutter-conventions` · `eld-design-system` · `eld-screens` · `flutter-drift` ·
`flutter-ble` · `hos-parity` · `mobile-security` · `flutter-testing`

## Qat'iy qoidalar
- `internal/hos` va `internal/sync` — faqat stdlib (Dart porti bilan bir xil test-vektorlar).
- sqlc modeli javobga chiqmaydi — faqat DTO. `company_id` faqat kontekstdan.
- Har handlerda to'liq swag annotatsiyasi (`@x-permission` shart), har DTO maydonida `example`.
- Migratsiyalar forward-only; mavjudini tahrirlash taqiq.
- Har bosqich oxirida `eld-security-auditor` + `eld-code-reviewer` yuritiladi.

## Mobil qat'iy qoidalar
- `mobile/packages/hos_engine` va `sync_core` — **sof Dart** (`flutter` bog'liqligi yo'q); Go `internal/hos` bilan bir xil vektorlardan o'tadi.
- Qatlam: `presentation → domain → data`. `eld_api` (generatsiya) modeli UI ga chiqmaydi.
- **UI Figma bilan piksel darajasida bir xil.** Etalon: `mobile/design/figma/` (JSON + light/dark PNG). Matnli tavsif emas, Figma kanonik.
- **Etalon rasm faqat `mobile/design/figma/png_ref/` dan o'qiladi** (siqilgan, o'rtacha 35 KB), `png/` dan emas (@2x, 680 KB gacha). Har etalon **bir marta** o'qiladi — rasm base64 sifatida kontekstda qoladi va har so'rovda qayta yuboriladi. Rang/spacing/radius rasmdan o'lchanmaydi — `tokens.json` dan olinadi. Batafsil: `png_ref/README.md`.
- Figma o'qish yo'li: Figma Desktop + Desktop Bridge plugini + `figma-console` MCP (`figma_*`). Rasmiy Figma MCP kvota sababli ishlatilmaydi.
- Taqiqlar (CI grep): `DateTime.now()` domen/paketlarda · `print(`/`debugPrint(` · hard-coded matn · hard-coded `Color(0x…)` · `http` paketi.
- Drift `schemaVersion` forward-only. Har bosqich oxirida `flutter-code-reviewer` + `mobile-security-auditor`.

## tz-mobile.md xaritasi (sed bilan qismini o'qi)
| Qatorlar | Mazmun |
|---|---|
| 69–170 | Stack, papka tuzilmasi, lint, muhitlar |
| 170–368 | Ikki qurilma profili, co-driver, auth, PIN, sessiya |
| 368–650 | Oflayn-first, Drift, outbox, sync protokoli, vaqt |
| 650–892 | HOS Dart porti, duty status oqimi, auto-DR |
| 892–1008 | ELD qurilmasi va BLE |
| 1008–1115 | **Dizayn tizimi (§11.0)** |
| 1115–1606 | **Ekranlar spetsifikatsiyasi va registrlar** |
| 1606–1868 | Sertifikatsiya, log tahrirlash, chat, push, fayllar |
| 1868–2026 | Xavfsizlik, platforma cheklovlari, NFR |
| 2026–2241 | Test, nomuvofiqliklar reestri |
| 2241–2658 | Ish tartibi, bosqichlar, DoD |
