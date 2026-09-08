# PARITY — support / sync / eld_device / diagnostics / notifications / drive_mode

11 ekran, bitta passda audit + tuzatish. Manba: `design/figma/MAP.md` §1,
`design/figma/spec/*.md`. png_ref bir marta ko'rildi (M-49, M-15) — qolganlarida
layout daraxti + matn jadvali yetarli bo'ldi.

## M-49 — Contact support (forma)
`node 1179:7028` / dark `2700:38501` — `support_form_screen.dart`
- [x] Doc-comment'dagi dark nodeId xato edi (`2665:28217`) — MAP.md dagi haqiqiy
  `2700:38501` ga tuzatildi.
- [x] App bar'da standart `bell/mail/refresh` guruhi ko'rinib turardi — Figma
  faqat orqaga tugmasi + sarlavha ko'rsatadi — `showDefaultActions: false`.
- [ ] Figma'da forma **modal** (fon — `Settings` ekrani, ustida oq karta);
  kod to'liq ekran sifatida chizadi (marshrut registrida `M-49` alohida
  ekran, TZ §11.1 kanonik) — **tuzatilmadi**, chunki registr ustuvor va
  o'zgartirish navigatsiya arxitekturasini buzadi.
- [ ] Radio halqa o'lchami Figma'da 20×20, kodda 24×24 — token
  tizimidan o'lchanmaydi (spec qoidasi), teginish maydoni M8 talabi ustun —
  **tuzatilmadi**.

## M-50 — Support & Helpdesk (ro'yxat)
`node 1179:7142` / dark `2665:36915` — `support_list_screen.dart`
- [x] Doc-comment'dagi node butunlay xato edi (`1179:6892`/`2665:28123`,
  Figma'da mavjud emas) — haqiqiy `1179:7142`/`2665:36915` ga tuzatildi.
- [x] `showDefaultActions: false` qo'shildi.
- [ ] Figma: pastki o'ngda **doira FAB** (`+`, 48×48, `primary`, `r24`).
  Kod: pastda **to'liq kengroq** `AppButton.primary` (`Add Ticket`).
  TZ dizayn-tizimi bo'sh holat matni "Start to add your first ticket by
  clicking button **below**" — bu ikkalasiga ham mos, lekin ilovaning boshqa
  ro'yxat ekranlari (DVIR va h.k., boshqa agent hududi) ham xuddi shu
  "pastki to'liq tugma" naqshini ishlatadi — bitta ekranni FAB ga
  o'zgartirish ilova bo'ylab nomuvofiqlik yaratardi. **Tuzatilmadi**,
  reestrga (`16-17-registry-open-questions.md` ekvivalenti — mobil loyihada
  §21) yozish tavsiya etiladi.

## M-51 — Support ticket thread
`node 1158:462` / dark `2665:35485` — `ticket_thread_screen.dart`
- [x] `showDefaultActions: false` qo'shildi (avval bell/mail/refresh ko'rinardi).
- Node ID izohi allaqachon to'g'ri edi.

## M-54 — Sync status (🎨 Figma yo'q)
`support/sync/presentation/screens/sync_status_screen.dart`
- [x] **Katta tuzatish:** ekran xom Material primitivlari (`Scaffold`,
  `AppBar`, `ListTile`, `Divider`, `Theme.of(context).colorScheme`) bilan
  yozilgan edi — `core/ui` dizayn tizimidan chetlashgan (taqiqlangan
  hard-coded rang/uslub, flutter-conventions taqiqlari). `AdaptiveScaffold`
  + `AppBarPrimary` + `SettingsCard`/`SettingsRow` + `StatusBadge` +
  `LoadingSkeleton`/`ErrorState` ga ko'chirildi — boshqa 🎨 ekranlar
  (`M-46 Diagnosis`) bilan bir xil naqsh.
- [x] Sana qiymatlari endi `AppFormats.fullDateTime` orqali (avval xom
  `toIso8601String()`).
- [x] Yangi `syncErrorLoading` ARB kaliti qo'shildi (`20_sync.arb`).

## M-55 — Sync conflicts (🎨 Figma yo'q)
`sync/presentation/screens/sync_conflicts_screen.dart`
- [x] Xuddi shu tuzatish: xom Material → `AdaptiveScaffold` + `AppBarPrimary`
  + `EmptyState`/`ErrorState`/`LoadingSkeleton` + `AppButton.text`.
- [x] Yangi `syncConflictsEmptyTitle` ARB kaliti qo'shildi.
- Testlar `--timeout=60s` bilan yurgizildi, osilib qolmadi (7/7 o'tdi).

## M-17/M-18 — ELD not connected / Permissions
`node 1107:2310` (M-18) / dark `2665:30606` — `permissions_screen.dart`
- [x] `showDefaultActions: false` qo'shildi.
- Qolgan tarkib (2 karta: ruxsatlar + tizim xizmatlari, badge matnlari
  `Allowed`/`Not allowed`/`On`/`Off`) allaqachon Figma bilan mos edi.
- M-17 (ELD not connected dialog) topshiriq doirasida emas (`connect`/
  `permissions` ekranlari so'ralgan) — tegilmadi.

## M-19 — ELD device connect/scan (🎨 Figma yo'q)
`eld_device/presentation/screens/eld_connect_screen.dart`
- [x] `showDefaultActions: false` qo'shildi.
- Qolgani (`SettingsCard`, handshake maydonlari, scan/connect oqimi) TZ
  §10.3 ga mos, allaqachon dizayn tizimidan foydalanadi — qo'shimcha
  tuzatish talab qilinmadi.

## M-46 — Diagnosis of device
`node 1131:965` / dark `2665:28907` — `diagnosis_screen.dart`
- [x] `showDefaultActions: false` qo'shildi.
- 3 qator (`ELD coordinates`, `GPS coordinates`, `Network quality`) + M77
  faol kodlar ro'yxati (dizaynda yo'q, TZ §10.6 talabi) — saqlanib qoldi,
  **o'chirilmadi** (TZ da bor, Figma'da yo'q bo'lsa ham kerak).

## M-47 — Check network
`node 1122:319` / dark `2665:29068` — `check_network_screen.dart`
- [x] `showDefaultActions: false` qo'shildi.
- `NetworkGauge` shkalasi (`0·1·5·10·20·30·40·50·75·100`) `kNetworkGaugeTicks`
  konstantasi orqali spec bilan **aynan mos** — tekshirildi, tuzatish
  kerak emas edi.

## M-43 — Notifications
`node 1156:7135` / dark `2665:35068`, bo'sh holat `1156:7244` —
`notifications_screen.dart`
- [x] **Bug:** app bar'da orqaga tugmasi umuman yo'q edi (`leading`
  berilmagan) — ekranga qo'ng'iroq ikonkasidan kirilgani uchun foydalanuvchi
  qayta chiqolmasdi. `AppBackButton` qo'shildi.
- [x] `showDefaultActions: false` qo'shildi (standart bell/mail/refresh
  o'rniga faqat `Mark all read`, TZ §15).
- Kun sarlavhasi formati Figma'dagi `May 28, 2025` emas, `EEE, MMM d`
  (`Tue, May 20`) — bu **M91 kanonik qaror** (dizayn-tizim skilida
  hujjatlashtirilgan), xato emas.

## M-15 — Drive mode (focused)
`node 1170:2684` / dark `2665:27572` — `drive_mode_screen.dart`
- [x] **Bug:** app bar'da standart bell/mail/refresh guruhi ko'rinardi —
  Figma'da yo'q **va** M58 ("chat/DVIR/sertifikatsiya bloklanadi haydash
  rejimida") talabiga zid edi (chat ikonkasi orqali chetlab o'tish mumkin
  edi). `showDefaultActions: false`.
- Qolgan tarkib (status qatori, katta halqa hisoblagich, info karta,
  `Off Duty`/`On Duty` tugmalari) Figma bilan mos, `DriveTimerRing` allaqachon
  token ranglarini ishlatadi.

## Umumiy tuzatish (barcha 11 ekranga tegishli)
`AppBarPrimary` standart holatda `bell/mail/refresh` amal guruhini
(`showDefaultActions`) chizadi — bu faqat asosiy tab ekranlari (Home, Logs,
Chat, Profile) uchun mo'ljallangan. Auditga kiritilgan barcha 9 ta orqaga
tugmali/sub-ekran (`M-49`, `M-50`, `M-51`, `M-15`, `M-18`, `M-19`, `M-43`,
`M-46`, `M-47`) da bu guruh Figma'da yo'q edi — hammasida
`showDefaultActions: false` qo'shildi. `M-43` da qo'shimcha ravishda yo'qolgan
orqaga tugmasi tiklandi.

## Tekshiruv natijalari
- `flutter analyze lib/features/{support,sync,eld_device,diagnostics,notifications,drive_mode}`
  → 0 xato/ogohlantirish.
- `flutter test test/features/{support,eld_device,diagnostics,notifications,drive_mode}`
  → 119/119 o'tdi.
- `flutter test test/features/sync --timeout=60s` → osilib qolmadi, 7/7 o'tdi.
- `flutter test test_goldens/features/{diagnostics,drive_mode,eld_device,notifications,support} --update-goldens`
  → 70/70 o'tdi, PNG'lar app bar o'zgarishini aks ettirish uchun yangilandi.
