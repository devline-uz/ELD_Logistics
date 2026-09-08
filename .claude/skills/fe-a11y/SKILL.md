---
name: fe-a11y
description: ELD Admin Panel uchun a11y (accessibility) ko'rik chek-listi — WCAG 2.1 AA. a11y-reviewer agenti yangi yoki o'zgargan ekran/komponentni tekshirganda, yoki PR review'da klaviatura/ARIA/kontrast/fokus muammolarini qidirganda shu skill'ni ishlat.
---

# FE A11y Review Checklist — WCAG 2.1 AA

Bu chek-list `a11y-reviewer` agenti uchun tekshiriladigan shaklda yozilgan. Har bandni PASS/FAIL sifatida belgila, FAIL bo'lsa aniq element/fayl/qatorni ko'rsat.

## 1. Klaviatura navigatsiyasi [MUST]

- [ ] Har bir interaktiv element (`button`, `a`, `input`, `select`, custom widget) `Tab` bilan yetiladi — `tabindex` bilan sun'iy ravishda chetlab o'tilmagan.
- [ ] Fokus **ko'rinadigan** halqa bilan ko'rsatiladi: `focus-visible`, 2px `primary` rang, hech qanday elementda `outline: none` fokus almashtiruvchisiz qo'llanilmagan.
- [ ] Tab tartibi vizual/mantiqiy tartibga mos (DOM tartibi ekrandagi o'qish yo'nalishiga mos).
- [ ] Modal ochilganda **fokus tuzoq** (`focus trap`) ishlaydi — `Tab`/`Shift+Tab` modal ichida aylanadi, orqa fondagi elementlarga o'tmaydi.
- [ ] Modal yopilganda fokus uni chaqirgan tugmaga qaytadi.
- [ ] `Esc` modalni yopadi (o'zgargan forma bo'lsa — tasdiq dialogi orqali).
- [ ] Bosiladigan jadval satri (`row click → View`) `role="button"` + `tabindex="0"` bilan belgilangan va `Enter`/`Space` orqali ham ishlaydi, sichqoncha bilan cheklanmagan.
- [ ] `Skip to content» havolasi mavjud va birinchi `Tab` bosilganda ko'rinadi.
- [ ] Dropdown/combobox/menyu strelka tugmalari (`↑/↓/Enter/Esc`) bilan boshqariladi.

## 2. ARIA qoidalari [MUST]

- [ ] Har bir `IconButton` da `aria-label` bor (matnsiz tugma hech qachon label'siz emas).
- [ ] Toast va yuklanish holatlari `aria-live="polite"` bilan e'lon qilinadi (xato uchun `role="alert"`, success/info uchun `role="status"`).
- [ ] Saralanadigan jadval sarlavhalarida `aria-sort` (`ascending`/`descending`/`none`) to'g'ri qo'yilgan.
- [ ] Xato bo'lgan forma maydonida `aria-invalid="true"` + `aria-describedby` xato matn elementiga ishora qiladi.
- [ ] Yuklanayotgan bloklarda `aria-busy="true"`.
- [ ] Modalda `aria-modal="true"` + `aria-labelledby` (sarlavha elementiga ishora).
- [ ] Majburiy maydonlarda vizual `*` bilan bir qatorda `aria-required="true"`.
- [ ] `Tabs` komponenti `role="tablist"`/`role="tab"`/`role="tabpanel"` va `aria-selected` to'g'ri ishlatilgan.
- [ ] Dekorativ ikonkalar `aria-hidden="true"` bilan belgilangan (skrin-rider ularni o'qimaydi).

## 3. Kontrast talablari [MUST] — WCAG 2.1 AA

- [ ] Oddiy matn kontrasti ≥ **4.5:1**, katta matn (≥18pt yoki ≥14pt bold) va UI elementlari ≥ **3:1**.
- [ ] `neutral-400` matn oq fonda — **yetarli emas**, faqat ikkilamchi/katta o'lchamdagi matnda ishlatiladi, asosiy matn uchun taqiqlanadi.
- [ ] `warning-base #F6BA47` oq fonda matn uchun **yetarli emas** — matnda o'rniga `warning-dark #7B5D24` ishlatiladi.
- [ ] Barcha badge fon/matn juftliklari (success/warning/error/neutral/info) kontrast bo'yicha tekshirilgan.
- [ ] Ma'no **faqat rang bilan berilmagan**: duty status chip'ida rang + matn kodi (`DR`), violation satrida rang + ikonka + `Violation:` prefiksi, KPI chizig'ida rang + qiymat birga ko'rsatiladi.

## 4. Fokus boshqaruvi [MUST]

- [ ] Sahifa yuklanganda/route almashganda fokus mantiqiy joyga (masalan `h1` yoki asosiy kontent) o'tkaziladi, foydalanuvchi yo'qotilmaydi.
- [ ] Sahifa tuzilishi: bitta `h1`, mantiqiy `h2/h3` ierarxiya, `<main>`, `<nav>` semantik teglar bilan.
- [ ] Dinamik ravishda qo'shilgan kontent (toast, yangi modal) fokusni to'g'ri boshqaradi — foydalanuvchi ekrandan "yo'qolib qolmaydi".
- [ ] `prefers-reduced-motion` hurmat qilinadi: animatsiyalar o'chiriladi, xarita `easeTo` → `jumpTo` ga almashtiriladi.

## 5. Axe yugurtirish tartibi [MUST]

- [ ] CI'da `axe-core` (Playwright bilan integratsiya) ishga tushirilgan.
- [ ] Kamida **asosiy 10 ekranda** (login, dashboard, units list, drivers list, unit view, driver logs, DVIR list, maintenance list, tracking, reports) axe skani bajariladi.
- [ ] Har skanda **kritik (critical) va jiddiy (serious) xato — 0** talabi qo'yilgan; CI shu shartda fail bo'ladi.
- [ ] Yangi ekran/komponent qo'shilganda uni ham axe skan ro'yxatiga qo'shish tavsiya etiladi (10 ekran — minimal, ko'payishi mumkin).
- [ ] Lokal tekshiruv uchun agent PR diff'idagi o'zgargan komponentni qo'lda ko'zdan kechirib, yuqoridagi 1–4 bo'limlar bo'yicha tekshiradi (axe faqat avtomatik aniqlanadigan qismni qamrab oladi — semantik/mantiqiy muammolarni qo'lda ko'rish kerak).

## To'liq manba

- TZ §14.2 (A11y), `docs/tz-admin-frontend.md` qatorlar 1637–1646 (F216–F222)
- Qo'shimcha bandlar (axe batafsil tartibi, fokus boshqaruvi kengaytmasi) — WCAG 2.1 AA standart amaliyotidan to'ldirilgan, TZ talablariga zid emas
