# PARITY-auth.md — auth/legal/feedback Figma parity audit

Hudud: `lib/features/{auth,legal,feedback}/`. Manba: `design/figma/MAP.md` §1/§3,
spec kartalari `design/figma/spec/`.

## Natija

| Ekran | Node (light) | Holat |
|---|---|---|
| M-01 Splash | `958:22` | o'lchandi, tuzatilmadi (mos) |
| M-04 PIN entry | — 🎨 | Figma da yo'q — o'tkazib yuborildi |
| M-05 Accept invitation | — 🎨 | Figma da yo'q — o'tkazib yuborildi |
| M-08 Two-factor (TOTP) | — 🎨 | Figma da yo'q — o'tkazib yuborildi |
| M-57 Force update | — 🎨 | Figma da yo'q — o'tkazib yuborildi |
| M-58 Sessions | — 🎨 | Figma da yo'q — o'tkazib yuborildi |
| M-56 Signed out elsewhere | — 🎨 | Figma da yo'q — o'tkazib yuborildi |
| M-52/M-53 Legal (Privacy/Terms) | `2627:25778` / `2627:25891` | o'lchandi, tuzatilmadi (mos) |
| M-48 Give feedback | `1131:1149` | o'lchandi, **1 ta tuzatish** |

## M-01 Splash (`auth/presentation/screens/splash_screen.dart`)
- [x] Fon `#FCFCFD` = `colors.bg` — mos.
- [x] Logotip markazda (`Center` + `Column(mainAxisSize.min)`), Figma dagi rasm
      `@96,368` markazga juda yaqin (852/2=426, rasm markazi≈425.5) — mos.
- [ ] Figma da logotip **rastr rasm** (`WhatsApp Image...` IMAGE fill 200.39×115.52),
      kodda `AuthBrandLogo` — matn (`One` + `Book ELD`) stack. **Tuzatilmadi**: bu
      widget `login_screen.dart` bilan **umumiy** (`auth_shell.dart`), login ekrani
      vazifa ta'rifida "TAYYOR — tegma" deb belgilangan; uni o'zgartirish login
      ekraniga ham ta'sir qiladi. Hisobotga qoldirilmoqda — qaror kerak
      (haqiqiy logotip rasm asseti kerak bo'lsa alohida CR).

## M-52/M-53 Legal (`legal/presentation/screens/legal_screen.dart`)
- [x] App bar sarlavha + orqaga tugma, taglar mos (`AppBarPrimary`+`AppBackButton`).
- [x] Sarlavha (`# ...`) → `body11` (16 Bold) = Figma "Heading" 16 Bold — mos.
- [x] Paragraf → `body15` (14 Regular) `textSecondary` (#777E90) = Figma "Overview"
      matni 14/25 `#777E90` — mos.
- [ ] Figma dagi haqiqiy matn (Jusoor/ONTime Log namunalari) mahsulot matni emas —
      kod to'g'ri ravishda placeholder (`_Placeholder`, M117) ko'rsatadi, chunki
      `assets/legal/*.md` bo'sh. Bu **kutilgan holat**, TZ §11 ochiq savoli (M117),
      tuzatish talab qilinmaydi.
- Figma'dagi "Contact On: Phone number" (italic, `#5D5C5D` token yo'q) qatori — asosiy
  matn manbasidan keladi (asset ichida), UI shablonida alohida uslub yo'q. Kontent
  kelganda ko'rib chiqiladi — kod tomonidan cheklanmagan.

## M-48 Give feedback (`feedback/presentation/screens/feedback_screen.dart`)
- [x] App bar, intro matn, 2 ta savol kartasi, Submit tugmasi — struktura to'liq mos
      (png_ref bilan tasdiqlandi).
- [x] Matnlar so'zma-so'z Figma bilan bir xil (`feedbackIntro`, `feedbackRatingQuestion`,
      `feedbackFeatureQuestion`, `feedbackTextHint = "Write here.."`, `feedbackSubmit`).
- [x] **Tuzatildi**: kartalar orasidagi bo'shliq `Spacing.cardGap` (15 dp) edi,
      Figma `Categories` freymi `gap25` (25 dp) belgilaydi → `Spacing.s25` ga
      o'zgartirildi (intro→karta1 oralig'i bilan bir xil bo'ldi).
- [ ] Figma'da Submit tugmasi fon rangi `#1C1E24` (deyarli qora), kulrang
      `#F5F5F5` panelda; kodda `AppButton.primary` (`colors.primary` — qizil),
      panelsiz. **Tuzatilmadi**: dizayn tizimi (`eld-design-system` skill, M86)
      bo'yicha `AppButton.primary` fon rangi hamma joyda `primary` — bitta ekran
      uchun maxsus qora tugma qo'shish tizim qoidasini buzadi. Nomuvofiqlik
      Figma template asl mahsulotidan (qora CTA) meros bo'lishi mumkin — CR kerak
      bo'lsa `docs`/`16-17` ga yozilishi kerak (bu modul chegarasidan tashqarida).
- [ ] `SettingsCard` ichidagi savol↔input orasidagi bo'shliq core komponentda
      hardcoded `Spacing.s10` (10 dp), Figma `gap15` (15 dp) ko'rsatadi. `core/ui/`
      tegilmaydi — faqat hisobotga yozildi.

## Umumiy
- `flutter analyze lib/features/auth lib/features/legal lib/features/feedback` →
  **issue yo'q**.
- `flutter test test/features/auth test/features/legal test/features/feedback` →
  **109/109 o'tdi**.
- Goldenlar yangilandi (`--update-goldens`): faqat `feedback_*` rasmlar mazmunan
  o'zgardi (spacing tuzatishi sababli); `auth`/`legal` goldenlarida piksel farqi
  environment shrift renderingiga bog'liq bo'lishi mumkin — kodda o'zgarish yo'q.
