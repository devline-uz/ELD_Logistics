---
name: mobile-security
description: ONEBOOK ELD mobil ilova xavfsizlik bazasi — token vault, refresh rotatsiyasi va mutex, sessiya siyosati, PIN, ekran himoyasi, PII maskalash, pinning, ruxsatlar va fayl yuklash. Auth, token, PIN, fayl yoki ruxsat kodi ustida ishlaganda va xavfsizlik ko'rigida majburiy.
---

# Mobil xavfsizlik bazasi (tz-mobile §4, §16, §17)

Mijoz (Flutter) tomoni. Qarama-qarshilikda `.claude/skills/eld-security` ustun.

## 1. Token vault — nima qayerda saqlanadi [MUST]

| Ma'lumot | Joy |
|---|---|
| `access_token` | **Faqat xotirada** (`String`, minimal umr). Diskka, prefs'ga, keshga **yozilmaydi** |
| `refresh_token` | `flutter_secure_storage`: iOS Keychain `first_unlock_this_device`, Android EncryptedSharedPreferences (Keystore, bo'lsa StrongBox) |
| `device_id` | Secure storage, barqaror UUID (birinchi ishga tushishda generatsiya) |
| PIN hash + salt | Secure storage |
| Drift DB | SQLCipher bilan shifrlanadi `[SHOULD]`; kalit Keystore/Keychain'da (`sqlcipher_flutter_libs`) |
| Imzo PNG, DVIR fotolari | Ilova sandbox'i (`getApplicationSupportDirectory`) — tashqi xotiraga **hech qachon** emas |

**SAQLANMAYDI:** ochiq PIN, parol, diskdagi access token, foydalanuvchi ismi/emaili crash reportda.
**M152 [MUST]** Token URL'da, log'da, analytics'da, crash reportda **hech qachon** ko'rinmaydi —
Dio interceptor `Authorization` ni `***` bilan almashtiradi.

## 2. Refresh rotatsiyasi va mutex [MUST] (§4.7)

- Access TTL — `app/config.access_token_ttl_seconds` (default 900 s).
- Muddat tugashiga **60 s qolganda** proaktiv `POST /auth/refresh` (401 ni kutmasdan).
- **Rotatsiya:** har refresh yangi refresh token qaytaradi, eskisi **darhol o'chiriladi**
  (secure storage'da faqat bitta joriy token qoladi).
- **Refresh mutex [MUST]:** parallel 401 lar uchun **bitta** refresh oqimi; qolgan so'rovlar
  navbatda kutadi va yangi token bilan **bir marta** takrorlanadi. Retry ikkinchi refresh'ni
  ishga tushirmaydi (aks holda rotatsiya poygasi → `token_reuse` → butun sessiya bekor).
- **Ikki slot (co-driver):** har slot uchun **mustaqil** mutex va token to'plami, aralashmaydi.
- Refresh `TOKEN_REVOKED` / `UNAUTHORIZED` qaytarsa: sessiya tozalanadi, **outbox saqlanadi**,
  `M-44 Signed out elsewhere` ekrani.

## 3. Sessiya siyosati (§4.6)

- Bir user uchun bir vaqtda: **1 web + 1 phone + 1 tablet**.
- Xuddi shu turdagi yangi login eskisini bekor qiladi. `LoginResult.replaced_session == true`
  bo'lsa yangi qurilmada banner: «Your other <phone|tablet> was signed out.»
- Eski qurilmada birinchi 401 `TOKEN_REVOKED` → `M-44` ekrani + `Sign in again`.
- **M17 [MUST]** Sessiya bekor qilinganda **oflayn navbat o'chirilmaydi** — eventlar saqlanadi
  (maks. 14 kun) va o'sha user qayta login qilganda yuboriladi. Boshqa user login qilsa,
  avvalgi navbat alohida saqlanadi, **aralashmaydi**.
- Bir `device_id` + ikki `user_id` (kabinadagi ikki haydovchi) — **ruxsat etilgan**.
- **Leave Truck ≠ Logout (M18):** `POST /auth/logout {pause:true}` → sessiya `paused`, refresh
  token **tirik qoladi**; BLE uziladi, fon xizmati to'xtaydi; qaytish faqat PIN orqali. To'liq
  `Logout` (`pause=false`) — faqat drawer'dan, outbox bo'sh bo'lmasa ogohlantiradi. Tarmoq
  yo'q bo'lsa `logout(pause)` outbox'ga tushadi, lokal holat **darhol** `paused`.
- **M13/M14:** birinchi login oflayn ishlamaydi; refresh token amal qilar ekan ilova to'liq
  oflayn ochiladi — ELD qonuniy talabi, bloklash taqiq.

## 4. PIN xavfsizligi (§4.5, §17.3)

- **Aynan 6 raqam.** Taqiqlanadi: 6 ta bir xil raqam, ketma-ketlik (`123456`, `654321`) —
  mijoz tomonida ham tekshiriladi.
- **M155 [MUST]** Lokal `Argon2id` (yoki `PBKDF2-HMAC-SHA256`, ≥100 000 iteratsiya) hash +
  **qurilmaga xos 32-baytli tasodifiy salt** (`Random.secure()`). PIN ochiq matnda hech
  qayerda saqlanmaydi va logga chiqmaydi.
- Solishtirish **doimiy vaqtda** (constant-time compare) — `==` taqiq.
- **Urinishlar limiti:** 5 noto'g'ri urinish → 60 s blok, keyingisi 5 daqiqa (eksponensial).
  Blok holati secure storage'da saqlanadi — ilovani o'chirib yoqish bilan tiklanmaydi.
- **M156 [MUST]** Server ustun: `PIN_LOCKED` kelsa lokal urinishlar ham bloklanadi.
  `PIN_NOT_SET` → PIN o'rnatish ekraniga majburiy yo'naltirish.
- **M16 oflayn PIN:** tarmoq yo'q bo'lsa lokal hash bilan tekshiriladi va `Return to truck`
  ruxsat etiladi; tarmoq qaytganda `POST /auth/pin/verify` fonda yuritiladi. Server rad etsa —
  sessiya darhol `paused` ga qaytariladi va haydovchiga xabar beriladi.
- PIN so'raladi: `Return to truck`, `Switch co-driver`, `Begin Inspection` dan chiqish, Kiosk'dan chiqish.
  **So'ralmaydi:** ilovani odatiy ochish (ELD uzluksizligi).

## 5. Ekran himoyasi

- **M157** `FLAG_SECURE` (Android) / iOS snapshot himoyasi faqat: `M-04 PIN`, `M-05 Invite`,
  `M-08 2FA`, `M-30 Sign`, `M-38 Begin inspection`. Boshqa ekranlarda **o'chiriladi**
  (support screenshot uchun) — ekrandan chiqishda flagni tozalashni unutma.
- **M158** `AppLifecycleState.inactive` da app-switcher ko'rinishi **blur overlay** bilan
  yopiladi (iOS snapshot PII saqlab qolmasligi uchun).

## 6. PII maskalash va log qoidalari

- **M159 [MUST]** Log fayllari va Sentry'ga **hech qachon**: token, parol, PIN, to'liq
  email/telefon, aniq lat/lng, imzo tasviri, chat matni.
- Maskalash formatlari: `j***e@example.com`, `+92 *** ** 88`, koordinata 1 kasrgacha (`31.5, 74.3`).
- **M160 [MUST]** Sentry `beforeSend` filtri majburiy; foydalanuvchi identifikatori sifatida
  faqat `user_id` (UUID) — ism/email yuborilmaydi.
- Loglar markaziy interceptor orqali o'tadi; `print`/`debugPrint` bilan javob tanasini chiqarish taqiq.
- **M163 [MUST]** Debug rejim, dev menyu, mock transport prod build'ga **kompilyatsiya qilinmaydi**
  (`kReleaseMode` + `--dart-define` guard).

## 7. Transport, pinning, integrity

- **HTTPS only**, TLS ≥1.2. Cleartext taqiq: `android:usesCleartextTraffic="false"`, iOS ATS istisnosiz.
- **M153 [MAY] Sertifikat pinning:** `eldapi.stackyard.uz` uchun SPKI pin — **ikkita pin majburiy**
  (asosiy + zaxira, rotatsiya uchun). Xato pin → so'rov bloklanadi, `M-55`: «Secure connection
  could not be verified.» Muddat: **11-bosqich** (store review'dan oldin) — noto'g'ri pin ilovani o'ldiradi.
- **M154 [MUST]** WebSocket faqat `wss://`, token **URL'da emas** — handshake header yoki
  birinchi `auth` freymida.
- **M161 [MAY] Root/jailbreak:** aniqlanadi, lekin **bloklamaydi** — faqat `X-Device-Integrity`
  sarlavhasi bilan serverga xabar beriladi (audit uchun).
- **M162 [MUST]** Deep link validatsiyasi: faqat `onebookeld://` sxemasi va `eld.stackyard.uz`
  hosti; boshqa host'lardan kelgan link **ochilmaydi**.

## 8. Ruxsatlar (permission) matritsasi va UI

- **M165 [MUST]** UI element `Profile.permissions[]` ga qarab ko'rsatiladi/yashiriladi. Bu
  **xavfsizlik chegarasi emas** — haqiqiy tekshiruv serverda; mijoz keraksiz xatodan saqlaydi.
- Permission yo'q bo'lsa tugma **yashiriladi** (sabab tushuntirilmasa, disabled emas).
- Haydovchi uchun kutilgan to'plam: `logs.read`, `logs.certify`, `logs.add_event`,
  `logs.approve_edit`, `logs.reject_edit`, `logs.claim_unidentified`, `dvir.create`, `dvir.read`,
  `dvir.certify`, `inspection.*`, `chat.read`, `chat.send`, `notifications.read`, `files.upload`,
  `support.create`, `support.read`, `feedback.create`, `trailers.read`, `defect_types.read`.
- Permission kalitlari bitta Dart const bloki sifatida saqlanadi; string literal tarqatish taqiq.

## 9. Fayl yuklash (§16)

- Oqim: `POST /files/presign {kind, content_type, size_bytes, filename}` → `PUT <upload_url>`
  (qaytgan `headers` bilan, bevosita object storage'ga) → domen so'roviga **faqat `key`**.
- `kind` oq ro'yxati: `dvir_photo` (≤5 ta, har biri ≤5 MB), `signature` (PNG ≤1 MB),
  `chat` (≤10 MB). `invoice` mobilda **ishlatilmaydi**.
- **M147 [MUST]** Foto siqish `Isolate` da: uzun tomoni ≤1600 px, JPEG sifat 80.
  **EXIF GPS olib tashlanadi** (PII), orientation saqlanadi.
- **M148** Server `max_bytes` va `413 FILE_TOO_LARGE` — kanonik; mijoz oldindan tekshiradi, lekin
  server javobiga bo'ysunadi.
- **M149** Oflayn navbat: fayl `app_support/pending_files/` da + `files_queue` yozuvi.
  `expires_at` o'tgan bo'lsa — **qayta presign**. Fayl yuklanmaguncha bog'liq domen so'rovi
  yuborilmaydi. `upload_url` log qilinmaydi (imzo parametrlari sir). **M150** imzo PNG oddiy
  sandbox fayli sifatida saqlanadi, secure storage'da emas.

## 10. `company_id` qoidasi

**M164 [MUST]** `company_id` mobil tomondan **hech qachon** so'rov tanasiga yoki query'ga
qo'yilmaydi — backend uni tokendan oladi. Login javobidagi `company_id` faqat ko'p-kompaniyali
super-admin uchun; haydovchi ilovasida **ishlatilmaydi**. `company_id` maydonli request DTO —
ko'rikda **xato**.

## Ko'rik chek-listi (OWASP MASVS L1)

- [ ] Access token faqat xotirada; refresh faqat `flutter_secure_storage` da (disk dump'da yo'q)?
- [ ] Bitta refresh mutex bormi, retry ikkinchi refresh chaqirmaydimi, slotlar mustaqilmi?
- [ ] Rotatsiyada eski refresh token darhol o'chiriladimi?
- [ ] PIN Argon2id/PBKDF2 + 32-baytli salt bilan hashlanganmi, taqqoslash constant-time'mi?
- [ ] PIN urinish limiti va server `PIN_LOCKED` ustunligi amal qiladimi?
- [ ] `FLAG_SECURE` faqat kerakli 5 ekranda yoqilib, chiqishda tozalanadimi? Background blur bormi?
- [ ] Log/Sentry'da token, PIN, email, aniq koordinata, chat matni yo'qmi (`beforeSend` bormi)?
- [ ] Cleartext o'chirilganmi, WS `wss://` va token URL'da emasmi?
- [ ] Deep link host/sxema oq ro'yxati bormi?
- [ ] Prod build'da dev menyu / mock transport kompilyatsiyadan chiqarilganmi?
- [ ] Fayl yuklashda EXIF GPS tozalanadimi, `kind`/hajm tekshiriladimi, `upload_url` log qilinmaydimi?
- [ ] Hech bir request DTO'da `company_id` yo'qmi (M164)?
- [ ] Tasodifiylik `Random.secure()` bilanmi (`Random()` taqiq)?
- [ ] Sessiya bekor bo'lganda outbox saqlanib qoladimi (M17)?
