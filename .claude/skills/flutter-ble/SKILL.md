---
name: flutter-ble
description: ELD qurilmasi bilan BLE aloqasi — EldTransport abstraksiyasi va mock, ulanish holatlari, ruxsatlar oqimi, handshake, bufer o'qish, Android foreground service / iOS background modes, malfunction kodlari va auto-DR mantiqi. core/eld, BLE, fon xizmati yoki auto-DR kodi ustida ishlaganda majburiy.
---

# ELD BLE va auto-DR (tz-mobile §9, §10, §18)
## 1. `EldTransport` abstraksiyasi (M79, M80, R2)
ELD modeli **hali tanlanmagan**. Shu sababli barcha qurilma bilan ishlash **faqat**
`core/eld/eld_transport.dart` dagi `abstract class EldTransport` orqali boradi:

```dart
abstract class EldTransport {
  Stream<EldConnectionState> get state;       // Connected/Connecting/NotConnected/Malfunction/Diagnostic
  Stream<EldTelemetryFrame> get telemetry;    // speed_kmh, lat/lng, odometer_m, engine_hours, ignition
  Stream<EldDiagnostic> get diagnostics;      // P/E/T/L/R/S/O kodlari
  Future<EldHandshake> connect({String? macOrId});
  Future<List<EldBufferedEvent>> readBuffer();  // M72
  Future<void> disconnect();
}
```
- Implementatsiyalar: `MockEldTransport` (**birinchi yoziladi**, ekranlar u bilan to'liq ishlaydi),
  `BlePlusEldTransport` (`flutter_blue_plus`), `VendorEldTransport` — Flutter paketi bo'lmasa
  `MethodChannel('eld/device')` + `EventChannel('eld/stream')`; baholash **1–2 hafta**, 6-bosqich boshida (M171).
- **Qat'iy:** UI/servis qatlami hech qachon `flutter_blue_plus` yoki vendor tipini import qilmaydi.
- `MockEldTransport` prodda **build qilinmaydi** (alohida TestFlight/review build — M168).
## 2. Ulanish holatlari
```
NotConnected ──(ruxsat+BT ok)──► Connecting ──(pair+auth+handshake)──► Connected
     ▲                              │ 20 s timeout / xato            │
     └──────────────────────────────┴────(uzilish, 30 s tiklanmasa)──┤
                                                                     ├─► Diagnostic (warning banner)
                                                                     └─► Malfunction (doimiy error banner, dismiss YO'Q)
Connecting kirishi: kv_settings da MAC/ID bo'lsa → reconnect; bo'lmasa → scan → tanlash ro'yxati
```
| Parametr | Qiymat |
|---|---|
| Skan timeout | **20 s**, filtr: xizmat UUID + qurilma nomi prefiksi |
| Reconnect backoff | **2 s → 5 s → 15 s → 60 s** (max 60 s), cheksiz |
| Uzilish → banner | 30 s ichida tiklanmasa `Disconnected` + telemetriyada `disconnected=true` |
| RSSI ogohlantirish | `< −90 dBm` `[MAY]` |
| Banner matni | kanonik: **`ELD · Not connected`** / `ELD · Connecting…` / `ELD · Connected` (M68) |

Oxirgi MAC/ID `kv_settings` da saqlanadi → keyingi sessiyada to'g'ridan-to'g'ri reconnect.
## 3. Ruxsatlar oqimi (M-08, M69, M70)
Ketma-ketlik **[MUST]**, birinchi logindan keyin onboarding sifatida:
```
1 Notifications → 2 Bluetooth → 3 Location (When in use) → 4 Location (Always, alohida ekran)
→ 5 POST_NOTIFICATIONS (Android 13+) + battery optimization istisnosi
```
| Platforma | Aniq nomlar |
|---|---|
| Android 12+ BLE | `BLUETOOTH_SCAN` (**`neverForLocation` QO'YILMAYDI**), `BLUETOOTH_CONNECT` |
| Android location | `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION` (Play review 1–3 hafta, R1) |
| Android 13+ | `POST_NOTIFICATIONS`; idle prompt uchun `SCHEDULE_EXACT_ALARM` `[SHOULD]` |
| Android batareya | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (tushuntirish bilan) |
| Android min | **API 29 (Android 10)** |
| iOS location | `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` |
| iOS BLE | `NSBluetoothAlwaysUsageDescription` |
| iOS min | **iOS 15+** |

- Rad etilsa ilova **bloklanmaydi**: drawer `Permissions` bandida qizil belgi + Home'da banner.
- «Don't ask again» → `openAppSettings()`.
- Ruxsat yetmasa dialog: «In order to connect to the ELD, you must allow all the permissions.» — `Cancel` / `Allow Permissions`.
## 4. Handshake va bufer
Handshake maydonlari: **firmware**, **VIN**, **RTC**, **odometer_m**, **engine_hours**.
- VIN unit VIN bilan solishtiriladi → mos kelmasa ogohlantirish (ulanish bloklanmaydi).
- **M71 [MUST]** RTC har handshake'da `TimeSource` ga beriladi (ustuvorlik: ELD RTC → server → telefon).
- Ulanish muvaffaqiyatli → `power_on` eventi outbox'ga.

**M72 [MUST] Bufer:** ulanishda `readBuffer()` chaqiriladi, oflayn yozilgan eventlar
(`power_on/off`, harakat) outbox'ga `client_event_id` bo'yicha deduplikatsiya bilan qo'shiladi.
Vendor ID barqaror bo'lmasa — **deterministik UUID v5**:
```
client_event_id = uuidV5(namespace, sha256(device_id + eld_seq + ts))
```
Takroriy o'qishda **ayni o'sha** ID chiqishi shart (aks holda server `duplicate` o'rniga dublikat yozadi).
## 5. Fon rejimi
**Android** — `foregroundServiceType="location|connectedDevice"`, ruxsatlar
`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `FOREGROUND_SERVICE_CONNECTED_DEVICE`
(Android 14+ da tur deklaratsiyasi majburiy). Doimiy bildirishnoma (`ongoing`, foydalanuvchi
o'chira olmaydi): **joriy status + `Driving Time Left`**.

**iOS** — `UIBackgroundModes`: `bluetooth-central`, `location`;
`CBCentralManagerOptionRestoreIdentifierKey` bilan **state restoration**;
`allowsBackgroundLocationUpdates = true`, `pausesLocationUpdatesAutomatically = false`.
Fon rejimi `Significant Location Change` + BLE restoration kombinatsiyasida; `background fetch`
ga **tayanilmaydi** (M167).

- **M73 [MUST]** Fon xizmati haydash rejimida **hech qachon** to'xtatilmaydi.
- **M74 [MUST]** iOS state restoration ishlagach ilova **darhol** sync scheduler'ni ishga tushiradi
  va oxirgi holatni Drift'dan tiklaydi.
## 6. Malfunction / diagnostic kodlari (M77)
| Kod | Ma'no | Mobil xatti-harakati |
|---|---|---|
| `P` | Power compliance | Doimiy qizil banner |
| `E` | Engine synchronization | Banner + `origin=manual_no_eld` rejimiga tayyorlik |
| `T` | Timing (>10 daq skew) | Banner, `TimeSource` `phone` ga tushadi |
| `L` | Positioning | Banner; location qo'lda kiritish majburiy |
| `R` | Data recording | Banner + «Free up device storage» |
| `S` | Data transfer | Banner: «Logs have not been transferred for \<n\> days» |
| `O` | Other | Banner |

**Banner qoidasi [MUST]:** matn **«ELD malfunction (\<kod\>) — keep paper logs»**, rangi Error,
**dismiss tugmasi YO'Q** — faqat holat tiklanganda yo'qoladi. Har malfunction →
`event_type=malfunction` outbox'ga (kod `notes` da yoki telemetriya nuqtasidagi `diagnostics[]` da).
**M78 [SHOULD]** `S` kodi mobil tomonidan ham chiqariladi: **8 kundan** ortiq muvaffaqiyatli push yo'q.

Diagnostika (`M-36`): `ELD coordinates` (oxirgi **60 s** da ELD lat/lng) · `GPS coordinates` (telefon fix)
· `Network quality` (oxirgi sync kechikishi). Speedtest **tashqi xizmat orqali emas** (M75).
## 7. Auto-DR (M56, M57)
```
speed >= hos_policy.motion_threshold_kmh (default 8 km/h)  ← manba: ELD/ECM, fallback GPS
   └─ uzluksiz >= 3 s  → status = DR (origin=auto, speed_kmh bilan), drive ekrani <= 1 s
to'xtash: speed == 0 va >= 3 s  → drive ekranidan chiqiladi, status DR da QOLADI (M59)
```
- `DR` tugmasi UI da **umuman yo'q** (M51); auto-DR eventi qo'lda o'zgartirilmaydi (`DR_IMMUTABLE`).
- PC rejimida harakat `DR` yozmaydi (OFF qoladi). YM'da tezlik > `ym_max_speed_kmh` (**32**) → YM yopiladi → `DR`.
- Login qilinmagan holda harakat → **unidentified driving** (qurilma o'zi yozadi).
- Drive ekrani `precache` bilan tayyorlanadi, animatsiya ≤ 200 ms.
- **M63 [MUST]** Haydash rejimida har **60 daqiqada** `event_type=intermediate` (`lat/lng`,
  `odometer_m`, `engine_hours`) — tahrirlanmaydi, grid'da ikonka bilan ko'rsatilmaydi.
## 8. Idle prompt (M60, M61, M62)
```
t=0     speed 0 va >= 3 s → to'xtash aniqlandi, taymer boshlanadi
t=5 daq → modal «You've been idle for 5 minutes. Are you still driving?»  [No] [Yes, driving]
t=6 daq → javob yo'q (1 daq) yoki [No] → status ON
```
- **Event vaqti = so'rov chiqqan payt** (5 daq oldingi to'xtash vaqti EMAS) — FMCSA 5+1 = 6 daqiqa.
- Kanonik tugma matni: **`Yes, driving`**.
- Ekran o'chiq bo'lsa ham: yuqori ustuvorlikdagi lokal bildirishnoma (full-screen intent /
  critical alert) + ovoz + tebranish; javob bo'lmasa `ON` eventi **fon xizmatida** yoziladi.
## 9. PC / YM toggle (M64, M65)
| Rejim | Kirish | Chiqish |
|---|---|---|
| PC (`OFF (PC)`) | `Off Duty` ostidagi toggle, **sabab matni majburiy** (≤60 belgi) | Qo'lda; yoki `ON`/`DR` ga o'tganda |
| YM (`ON (YM)`) | `On Duty` ostidagi toggle, sabab ixtiyoriy | Qo'lda; yoki **avtomatik** tezlik > 32 km/h |

- `allow_pc`/`allow_ym` `false` → toggle **yashiriladi** (disabled emas).
- Server `pc_not_allowed`/`ym_not_allowed` qaytarsa — policy keshi eskirgan, darhol `sync/pull`.
- Grid'da: `OFF` chizig'i ustida `PC`, `ON` chizig'i ustida `YM` yorlig'i.
- ELD ulanmagan holda status o'zgarishi **mumkin** (M66): `origin=manual_no_eld`,
  `time_source=phone`, `time_unverified=true`, `odometer_m`/`engine_hours` = `null`.
## 10. Risklar (§18.5)
| № | Risk | Yumshatish |
|---|---|---|
| R1 | Play `ACCESS_BACKGROUND_LOCATION` review rad etadi | Erta ariza (5-bosqich), video demo + huquqiy asos, zaxira: faqat foreground |
| R2/R3 | ELD modeli tanlanmagan, vendor SDK Flutter'da yo'q | `EldTransport` + `MockEldTransport` birinchi; platform channel, 2 hafta bufer |
| R5 | iOS BLE fon rejimida uzilish | State restoration + ELD lokal buferi (M72) |
| R6 | Batareya iste'moli >25% (NFR) | Telemetriya batchlash, adaptiv GPS chastotasi, profiling 11-bosqichda |
| R8 | Kiosk device-owner; OEM (Xiaomi/Huawei/Oppo) autostart | Android `startLockTask()` fallback; iOS'da dasturiy kiosk **yo'q** (Guided Access qo'lda) |
