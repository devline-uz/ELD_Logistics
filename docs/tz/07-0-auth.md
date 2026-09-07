# 7. Ekranlar spetsifikatsiyasi

## 7.0 Yozuv formati va umumiy qoidalar

Har ekran uchun: **maqsad · marshrut · ruxsat · endpointlar (`METHOD /path`) · ustunlar/maydonlar · filtrlar · amallar · holatlar · bo'sh/xato holati**.

**F77 [MUST] Minimal kenglik — 1280 px.** Dizayn 1440 px uchun. 1280–1439 px: sahifa padding 40 → 24 px, KPI kartalari 4 → 2 ustun, jadval gorizontal scroll bilan. `<1280 px`: «This panel requires a screen at least 1280 px wide» xabari + o'lchamni o'zgartirish taklifi. Planshet/telefon uchun web admin **qo'llab-quvvatlanmaydi** (haydovchi ilovalari alohida).
**F78 [MUST]** Har ekran `<title>` va `h1` — i18n kalitidan; breadcrumb marshrut ierarxiyasidan.
**F79 [MUST]** Barcha `id` — UUID. URL'da UUID ko'rinadi; foydalanuvchiga esa **inson o'qiy oladigan identifikator** (Unit #, Ticket #, Driver name) ko'rsatiladi.

---

## 7.1 Auth (nav tashqarisida, `AuthLayout`)

### 7.1.1 Login — `/login`
- **Ruxsat:** public. **Endpoint:** `POST /auth/login`
- **Maydonlar:** `Email or username *`, `Password *` (ko'z ikonkasi), `Remember this device` (checkbox → `device_id` `localStorage`da saqlanadi)
- **Amallar:** `Sign in` · «Forgot password?» havolasi
- **Holatlar:** `requires_totp_setup` → `/2fa/setup`; `replaced_session` → toast; `subscription_readonly` → banner; `403 ACCOUNT_INACTIVE` → inline xato; `429` → countdown
- **Xato:** kirish xatosi **maydonga bog'lanmaydi** (qaysi maydon noto'g'ri ekanini oshkor qilmaslik uchun) — forma tepasida umumiy xato
- 🎨 Login ekrani dizaynda **yo'q** (grid'da `Login` 5-ustunli styli bor, ekran chizilmagan) → brend panel rangi + logotip + markazlashgan karta (maks. 440 px)

### 7.1.2 Two-factor — `/2fa/setup`, `/2fa/verify`
- **Endpoint:** `POST /auth/2fa/setup` (QR + secret), `POST /auth/2fa/verify` (6 xonali kod)
- Faqat cheklangan token bilan kirish mumkin; boshqa marshrutlar bloklangan. 🎨 dizayn yo'q.

### 7.1.3 Parolni tiklash — `/forgot-password`, `/reset-password?token=`
- **Endpoint:** `POST /auth/password/forgot`, `POST /auth/password/reset`
- Forgot: har doim bir xil neytral javob («If the account exists, a link has been sent») — enumeratsiyaga qarshi.
- Reset: `New password *` + `Confirm *`, kuch indikatori (`tz.md` §18.3: ≥ 10 belgi, harf + raqam).

### 7.1.4 Taklifni qabul qilish — `/invitation/accept?token=`
- **Endpoint:** `POST /auth/invitation/accept` — parol o'rnatish, profilni yakunlash.
- ✅ Bu **yagona** parol o'rnatish yo'li (`tz.md` qaror 21). Driver/User formalarida `Password` maydoni **yo'q** (§16).

---

