# ELD Admin Panel — loyiha konteksti

ONEBOOK ELD platformasining **web admin paneli**. Texnik topshiriq: `docs/tz-admin-frontend.md`.

## Ish protokoli (TZ §18)
Ish **bosqichma-bosqich, subagentlar orqali** bajariladi. Asosiy sessiya kod yozmaydi —
u bosqichni rejalashtiradi, subagentlarga topshiradi, natijani birlashtiradi va tekshiradi.

- **Vazifalar reestri:** `tasks.md` — har bajarilgan vazifa `[x]` bilan belgilanadi.
- **Subagentlar:** `.claude/agents/` (11 ta)
- **Skillar (siqilgan bilim):** `.claude/skills/fe-*` (10 ta) — TZ ni qayta o'qimaslik uchun
- **Ekran spetsifikatsiyalari:** `docs/tz/07-*.md` — modul bo'yicha bo'lingan, agent faqat o'zinikini o'qiydi

## Muhim manzillar
| Nima | Qiymat |
|---|---|
| API (prod) | `https://eldapi.stackyard.uz/api/v1` |
| Swagger spec | `GET /api/docs/swagger.json` — klient generatsiyasining yagona manbai |
| WebSocket | `wss://eldapi.stackyard.uz/api/v1/ws` |
| Admin domeni | `https://eldadmin.stackyard.uz` |
| API versiyasi | `v1` — **muzlatilgan** |

## Buzilmas qoidalar
- **Backend haqiqat manbai.** Dizayn bilan to'qnashsa — backend ustun; farq §16 reestriga yoziladi.
- Backend `backend/` papkasiga **yozilmaydi**; migratsiya yo'q.
- `src/api/schema.d.ts` — generatsiya (`npm run api`), qo'lda tegilmaydi.
- Kodda **hardcode string yo'q** — barcha matn `en.json` da.
- Admin panel **hech qachon** haydovchi nomidan log yozmaydi va imzo qo'ymaydi.
  Log tahrirlash — faqat **taklif → haydovchi tasdig'i** modeli orqali.
- Access token faqat xotirada; refresh token `sessionStorage` da. `localStorage` da token yo'q.
- Parallel agentlar `router.tsx`, `en.json`, `tailwind.config.ts`, `api/queries/index.ts` ga yozmaydi.

## Har bosqich oxirida (MUST)
```bash
cd admin && npm run typecheck && npm run lint && npm run test && npm run build
```
To'rttasi yashil bo'lmasa bosqich tugallanmagan. Keyin ikki ko'rik:
`frontend-security-reviewer` + `frontend-code-reviewer` — kritik topilma 0 bo'lishi shart.

## Git
Har bosqich alohida branch: `feat/stage-<n>-<nom>`. `main` ga to'g'ridan-to'g'ri push yo'q.
