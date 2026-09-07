---
name: fe-realtime
description: ELD Admin Panel frontendida WebSocket real-vaqt ulanishi, kanallarga subscribe/unsubscribe, reconnect strategiyasi va useChannel() hook yozish yoki tahrirlashda ishlatiladi.
---

# Real-vaqt (WebSocket)

Manba kontrakt: `backend/docs/websocket.md` (Swagger'da yo'q — bu **yagona** kontrakt).

## Ulanish va auth [MUST]

- **URL:** `wss://eldapi.stackyard.uz/api/v1/ws`
- **F154 [MUST] Token URL'da — QAT'IY TAQIQ.** `?token=`, `?access_token=`, `?jwt=`, `?bearer=`, `?authorization=`, `?api_key=` ishlatilmaydi — backend handshake'ni `401` bilan uzadi. Kredensial URL'da access-log, referer va proxy keshiga sizadi.
- Brauzer `WebSocket` API upgrade so'rovida qo'shimcha header yubora olmaydi → header'siz ulanish + **10 soniya ichida** birinchi freym sifatida auth yuboriladi:

```json
{"type":"auth","token":"<access_token>"}
```

- Muvaffaqiyatda server quyidagini yuboradi:

```json
{"type":"welcome","ts":"…"}
```

  Bu freymdan **oldin hech qanday `subscribe` yuborilmaydi**.
- Super Admin rejimida `X-Company-Id` header'i kerak, brauzer WS'da bera olmaydi → **F155**: super-admin tenant rejimida real-vaqt **o'chiriladi** (polling'ga o'tadi) yoki `auth` freymiga `company_id` maydonini qo'shish CR sifatida chiqadi (§17).

## Kanallar [MUST]

| Kanal | Ruxsat | Nima uchun (event turi) | Qaysi ekranda |
|---|---|---|---|
| `tracking` | `tracking.view_live` | `unit_last_state` | Dashboard xaritasi, `/tracking`, Track on Map |
| `notifications` | authenticated | `notification_created` | Global (header dropdown + toast) |
| `chat` | `chat.read` | `chat_message`, `chat_message_read` | `/chat` (global — o'qilmagan hisoblagich uchun) |
| `dashboard` | `dashboard.read` | `dashboard_summary` | `/` |

**F156** `notifications` — **global**, ilova ochilishi bilan obuna bo'linadi (unmount bo'lmaydi). `tracking`, `chat`, `dashboard` — **ekranga bog'liq**: komponent `mount` bo'lganda `subscribe`, `unmount` bo'lganda `unsubscribe`.

## Subscribe formati [MUST]

```json
{"type":"subscribe","channel":"tracking",
 "filter":{"unit_ids":["…"]},
 "since":"2026-09-06T17:55:00Z"}
```

- `filter.unit_ids` / `driver_ids` — **maksimum 500 id**. Ko'proq kerak bo'lsa filtrsiz obuna + klient tomonda filtrlash.
- `filter.company_id` **hech qachon yuborilmaydi** — yuborilsa o'z kompaniyasi bo'lishi shart, aks holda `FORBIDDEN`. Ortiqcha va xatarli.
- Javob: `{"type":"subscribed","channel":"…"}` — shundan keyingina ma'lumot keladi (**deny-by-default**).

Unsubscribe:

```json
{"type":"unsubscribe","channel":"tracking"}
```

## `since` backfill semantikasi [MUST]

**F157** Qayta ulanishda `since` = **oxirgi qayta ishlangan hodisaning `ts`**i (kanal bo'yicha alohida saqlanadi, masalan Zustand yoki local store'da per-channel `lastTs`).

- Replay freymlari `"replay": true` bilan keladi → **toast chiqarilmaydi**, faqat kesh yangilanadi (dublikat bildirishnomaning oldini oladi).
- Maksimum **200 hodisa** har kanal uchun; `since` **24 soatdan** uzoq bo'lsa jimgina qisqartiriladi; kelajakdagi `since` yuborilsa → xato kodi `TIME_IN_FUTURE`.
- **`since` — kafolat emas.** REST doimo haqiqat manbai (source of truth): qayta ulanishdan keyin tegishli query'lar ham `invalidate` qilinadi (masalan React Query `invalidateQueries`).

## Qayta ulanish strategiyasi [MUST]

`reconnecting-websocket` kutubxonasi sozlamalari:

| Parametr | Qiymat |
|---|---|
| `minReconnectionDelay` | 1000 ms |
| `maxReconnectionDelay` | 30 000 ms |
| `reconnectionDelayGrowFactor` | 1.5 (eksponensial + ±20% jitter) |
| `maxRetries` | `Infinity` |
| `connectionTimeout` | 10 000 ms |

**F158** Ulanish holati global (`Zustand`): `connecting | open | reconnecting | offline`.
- `reconnecting` holati **10 soniyadan** uzoq davom etsa — header ostida ingichka sariq banner: «Live updates paused. Reconnecting…» + `Retry now` tugmasi.
- Bu paytda ekranlar **60 s polling'ga** o'tadi (fallback).

**F159** Har muvaffaqiyatli ulanishdan keyin tartib: `auth` yuborish → `welcome` kutish → barcha faol kanallarga `since` bilan `subscribe`.

**F160** Access token yangilanganda (F15) — WS **yopilmaydi**; server obunani sessiya bo'yicha ushlaydi. Faqat to'liq logoutda yopiladi (close kod `1000`).

**F161** `document.visibilityState === 'hidden'` **5 daqiqadan** ortiq davom etsa — ulanish yopiladi (batareya/resurs tejash uchun); tab qaytganda `since` bilan qayta ulanadi.

## Ping/pong va limitlar

| Sozlama | Qiymat |
|---|---|
| Server ping intervali | 30 s |
| O'qish deadline | 65 s |
| Auth deadline | upgrade'dan keyin 10 s |
| Maksimal kiruvchi freym | 32 KiB |
| Chiquvchi navbat | 256 xabar |

**F162** Brauzer protokol-darajadagi `pong`ni avtomatik yuboradi — qo'shimcha kod kerak emas. Lekin **60 soniyada bir marta** amaliy keepalive yuboriladi:

```json
{"type":"ping"}
```

Proxy timeout'lariga qarshi. `pong` **10 soniya** ichida kelmasa — ulanish majburan qayta ochiladi.

**F163** Navbat to'lib ketishi mumkin (server xabarlarni tashlaydi) — shuning uchun **hech qanday holat faqat WS'ga tayanmaydi**: har WS hodisasi keshni yangilaydi, lekin ekranga kirishda doim REST so'rovi bo'ladi.

## Xatolar

Freym darajasidagi xato formati:

```json
{"type":"error","channel":"chat","code":"FORBIDDEN","message":"…"}
```

- Freym darajasidagi xato **socketni yopmaydi**.
- `FORBIDDEN` / `NOT_FOUND` → UI o'sha kanalga qayta obuna bo'lishga urinmaydi, ekran REST'ga tayanadi, `console.warn` chiqariladi.
- `UNAUTHORIZED` → socket yopiladi → token yangilanadi → qayta ulanish qilinadi.

## `useChannel()` hook API shakli

Kontsept — har ekran/komponent quyidagi shaklda foydalanadi:

```ts
const { status, lastEvent, error } = useChannel('tracking', {
  filter: { unit_ids: unitIds },   // ixtiyoriy, maks 500 id
  enabled: true,                    // mount/unmount bilan subscribe/unsubscribe
});
```

- Hook global WS mijozidan (singleton, `reconnecting-websocket` ustidan wrapper) foydalanadi, har komponent o'z ulanishini ochmaydi.
- `mount` → `subscribe` (agar `welcome` allaqachon kelgan bo'lsa darhol, aks holda navbatga qo'yiladi va `welcome`dan keyin yuboriladi).
- `unmount` → `unsubscribe`.
- `replay: true` freymlar `lastEvent`ni yangilaydi, lekin toast/side-effect trigger qilmaydi.
- Global qatlamda ulanish holati banneri va 60s polling fallback yuqoridagi F158 asosida ishlaydi — bu hook darajasida emas, ilova ildizida (`App` yoki `RealtimeProvider`) joylashadi.

## To'liq manba

`docs/tz-admin-frontend.md`, §8 «Real-vaqt (WebSocket)», qatorlar 1349–1427.
