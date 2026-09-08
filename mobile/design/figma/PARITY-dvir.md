# PARITY — dvir / certify / inspection / log_edits (audit)

Audit sanasi: 2026-09-08. Har ekran uchun spec (`design/figma/spec/`) + png_ref (bir marta,
faqat noaniq joylarda) solishtirildi. Xulosa: barcha 6 ta Figma-li ekran **allaqachon**
to'g'ri implementatsiya qilingan — kod izohlarida aniq nodeId, TZ qatorlari va normalizatsiya
qarorlari (#B-12, #B-13, #B-14, M104, M107, M109, M110) ko'rsatilgan; golden testlar mavjud
va o'zgarishsiz o'tdi (pixel parity allaqachon mavjud edi).

## `lib/features/dvir/presentation/screens/dvir_defect_picker_screen.dart` — M-33
Node: `1169:1467` (`vehicle defects`). png_ref bilan solishtirildi.
- [x] Ro'yxat tuzilishi (checkbox + label + `Accident Photo` alohida blok) mos.
- [x] `Engine` dublikati va `Refresh` bandi ko'rsatilmaydi — bu Figma dagi xato/artefaktni
      olib tashlash sifatida kod izohida (#B-12) hujjatlashtirilgan, TZ ga zid emas.
- [x] Yopish tugmasi `X` (`AppBarPrimary` leading `Icons.close`) — Figma bilan mos.
- [ ] Qidiruv maydoni (`AppTextField` search) Figma da yo'q — bu UX qo'shimchasi (funksional
      ehtiyoj, TZ #1367-1378 asosida), Figma dan hech narsa olib tashlanmagan, shuning uchun
      o'zgartirilmadi.

## `lib/features/dvir/presentation/screens/dvir_details_screen.dart` — M-35
Node: `1166:869` (`Eac row (on-click)`). png_ref bilan solishtirildi.
- [x] Time / Location / Odometer qatorlari, Truck/Trailer defects bo'limlari mos.
- [ ] Figma modal ko'rinishida (`X` yopish, Home fonida overlay), kodda esa
      `AppBarPrimary` + orqaga strelka bilan to'liq ekran — bu butun ilova bo'ylab yagona
      `AdaptiveScaffold`/`AppBarPrimary` konventsiyasi (boshqa modul agentlari ham shu
      naqshni ishlatadi), o'zgartirilmadi — buzilish xavfi past, lekin registrga yozish
      tavsiya etiladi (quyida).
- [x] M107 (faqat o'qish, tahrir/o'chirish tugmasi yo'q) — kod mos.

## `lib/features/dvir/presentation/screens/dvir_review_screen.dart` — M-34 / M-34v1 / M-34v2
Node: `1090:4687` / `1090:4901` / `1090:5027`. png_ref bilan solishtirildi.
- [x] `No Defects` checkbox, `Driver Signature` + `SignaturePad`, `Cancel`/`Confirm` mos.
- [x] M-34v1 dagi `Selected defects needs to be fixed` / `Selected defects fixed` radio
      juftligi **qasddan olib tashlangan** — kod izohida M104 sifatida hujjatlashtirilgan
      (`repaired` holatini faqat mexanik qo'yadi). Tuzatish talab qilinmaydi.

## `lib/features/certify/presentation/screens/certify_sign_screen.dart` — M-30
Node: `1102:817` (light) / `2665:31395` (dark). Ikkala png_ref ham solishtirildi.
- [x] `Driver Signature` + `Use my signature` chip + `SignaturePad` + `Save my signature`
      checkbox + sertifikatsiya matni + `Cancel`/`Confirm` — barchasi mos.
- [x] Dark variant `core/ui` tokenlaridan avtomatik hosil bo'ladi (Figma dark node bilan
      mos ranglar `AppColors` orqali).

## `lib/features/inspection/presentation/screens/inspection_kiosk_screen.dart` — M-38
Node: `1111:8013` (light) / `2665:29318` (dark). png_ref bilan solishtirildi.
- [x] Sana tasmasi (`DateStrip8Day`), 24 soatlik grid, Log Form shapkasi, eventlar jadvali
      mos.
- [ ] Figma da `< Log Report` app bar ko'rinadi, kodda esa app bar/orqaga tugmasi **yo'q**
      (`PopScope(canPop: false)`, faqat `Exit` tugmasi) — bu **qasddan** TZ §M110/M109
      talabiga ko'ra (kiosk rejimida navigatsiya bloklanishi kerak), kod izohida tz-mobile
      1427–1443 qatorlariga bevosita havola bor. Tuzatish talab qilinmaydi.

## `lib/features/inspection/presentation/screens/inspection_report_screen.dart` — M-37
Node: `1111:7825` (light) / `2665:27860` (dark). png_ref bilan solishtirildi.
- [x] 3 ta amal kartasi (`Review the logs…` / `Send the logs… via email` / `Send the ELD
      output file…`) sarlavha+tavsif+tugma bilan piksel darajasida mos.
- [x] Oflaynda email/fayl amallari o'chishi (`hint` matni) — Figma da yo'q, lekin TZ M108
      talabi, hech narsa olib tashlanmagan.

## `lib/features/log_edits/presentation/screens/pending_edits_screen.dart` — M-26 🎨
## `lib/features/log_edits/presentation/screens/pending_edit_detail_screen.dart` — M-27 🎨
MAP.md §3 da ro'yxatga olingan: **Figma da yo'q** (dizaynga hali qo'shilmagan, faqat
registrda mavjud). O'tkazib yuborildi — solishtirish uchun etalon yo'q.

## Ochiq savol (registrga tavsiya)
- M-35 (DVIR details) Figma da modal (`X` yopish, Home foni ustida) sifatida chizilgan,
  lekin butun `dvir`/`certify`/`inspection` modullari yagona `AppBarPrimary` to'liq ekran
  konventsiyasini ishlatadi. Bu ehtimol qasddan normalizatsiya (T-modallar planshet uchun
  alohida `Pane` variantlari orqali qoplanadi — masalan `CertifySignPane`), lekin `dvir`
  da bunday `Pane` yo'q. `docs`/`16-17-registry-open-questions.md`ga yozish tavsiya
  etiladi — modul egasi tasdiqlasin.
