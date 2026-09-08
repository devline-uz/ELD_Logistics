# ONEBOOK ELD — Release checklist

Bu hujjat **faqat chiqarish jarayoni** haqida. Sirlar (keystore paroli, `.p8`, API kaliti)
**hech qachon** repoga yozilmaydi — faqat lokal fayl (`.gitignore` da) yoki CI secret.

---

## 1. Platforma bazasi

| | Android | iOS |
|---|---|---|
| Minimal | `minSdk 29` (Android 10) | `IPHONEOS_DEPLOYMENT_TARGET 15.0` |
| Target | `flutter.targetSdkVersion` (Flutter SDK bilan yangilanadi) | eng yangi SDK |
| Paket ID | `uz.stackyard.eld_mobile` | `uz.stackyard.eld_mobile` |
| Artefakt | AAB (Play), APK faqat ichki test | IPA (TestFlight → App Store) |
| Kod qisqartirish | R8 yoqilgan (`isMinifyEnabled`, `isShrinkResources`) — `android/app/proguard-rules.pro` | Bitcode yo'q |

---

## 2. Imzolash kaliti (Android) — S-H3

### 2.1 Kalit qayerda
- **Upload keystore** (`.jks`) **repodan tashqarida** saqlanadi (masalan `~/keys/onebook-eld-upload.jks`)
  va parol menejerida zaxiralanadi. Yo'qolsa Play Console'dan upload key reset so'raladi (bir necha kun).
- **App signing key** — Play App Signing'da Google saqlaydi (tavsiya etilgan rejim).
- `.gitignore` da: `/android/key.properties`, `**/*.jks`, `**/*.keystore`, `**/*.p8`, `**/*.p12`,
  `**/*.mobileprovision`, `**/*.cer`, `/ios/Runner/ExportOptions.plist`.

### 2.2 Kalit yaratish (bir marta)
```bash
keytool -genkey -v -keystore ~/keys/onebook-eld-upload.jks \
  -keyalg RSA -keysize 4096 -validity 10000 -alias onebook-eld-upload
```

### 2.3 `android/key.properties`
`android/key.properties.example` dan nusxa oling va to'ldiring:

```properties
storeFile=/ABSOLUTE/PATH/OUTSIDE/REPO/onebook-eld-upload.jks
storePassword=...
keyAlias=onebook-eld-upload
keyPassword=...
```

Fayl **yo'q bo'lsa** release build **aniq xato bilan to'xtaydi** (`build.gradle.kts` dagi
`gradle.taskGraph.whenReady` tekshiruvi). Debug kalitga jimgina tushish taqiq.
Debug/profile build'lar bu fayldan mustaqil ishlaydi.

### 2.4 CI (GitHub Actions) — secret'lardan generatsiya
Secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.

```bash
echo "$KEYSTORE_BASE64" | base64 -d > "$RUNNER_TEMP/upload.jks"
cat > mobile/android/key.properties <<EOF
storeFile=$RUNNER_TEMP/upload.jks
storePassword=$KEYSTORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASSWORD
EOF
```
Job oxirida `rm -f "$RUNNER_TEMP/upload.jks" mobile/android/key.properties`.

---

## 3. iOS sertifikatlari

| Nima | Qayerda |
|---|---|
| Distribution certificate + provisioning profile | Apple Developer akkaunti; CI da `MATCH_*` yoki `APPLE_CERT_P12_BASE64` secret |
| App Store Connect API key (`AuthKey_XXXX.p8`) | **Faqat** CI secret (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_BASE64`) |
| Push (APNs) kaliti `.p8` | Firebase Console'ga yuklanadi, repoda saqlanmaydi |

`ios/Runner/GoogleService-Info.plist` va `android/app/google-services.json` — `.gitignore` da,
CI da secret'dan yoziladi.

### 3.1 TLS sertifikat pinning — `CERT_SPKI_PINS` (M153, #B-131)

Pinning **fail-closed**: `ENABLE_CERT_PINNING=true` bo'lsa-yu pin ro'yxati bo'sh bo'lsa,
`Env.validate()` ishga tushishda `StateError` beradi —
«`CERT_SPKI_PINS to'ldirilmagan …`». Bu **kutilgan xatti-harakat**: `env/prod.json` da
soxta/o'ylab topilgan pin **saqlanmaydi**, chunki noto'g'ri pin butun ilovani o'ldiradi.
Pinlar faqat haqiqiy sertifikatdan olinadi va CI secret'i sifatida beriladi.

Pin = leaf sertifikat `SubjectPublicKeyInfo` (DER) ning SHA-256 hashi, base64 da.

```bash
# 1) Joriy (asosiy) pin — ishlab turgan serverdan
openssl s_client -servername eldapi.stackyard.uz -connect eldapi.stackyard.uz:443 </dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary | base64

# 2) Zaxira pin — keyingi rotatsiya uchun tayyorlangan CSR/kalitdan (server jamoasidan)
openssl pkey -pubin -in backup_pubkey.pem -outform der \
  | openssl dgst -sha256 -binary | base64
```

**Ikkita pin majburiy** (asosiy + zaxira) — rotatsiya paytida eski ilova versiyalari
ishlashda davom etadi. Build:

```bash
flutter build appbundle --release --dart-define-from-file=env/prod.json \
  --dart-define=CERT_SPKI_PINS="<asosiy>,<zaxira>"
```

CI da qiymat `CERT_SPKI_PINS` secret'idan olinadi; repoga **kommit qilinmaydi**.
Sertifikat yangilanganda: avval zaxira pinni yangi sertifikatga moslab chiqarish,
so'ng serverni almashtirish (aks holda eski build'lar uziladi).

### 3.2 Deep link — domen tasdiqlash (M162, #B-132)

`onebookeld://` sxemasidan tashqari `https://eld.stackyard.uz/...` ham ilovada ochiladi
(Android App Links / iOS Universal Links). Ular ishlashi uchun **serverga fayl qo'yish shart**:

| Platforma | Fayl | Mazmun |
|---|---|---|
| Android | `https://eld.stackyard.uz/.well-known/assetlinks.json` | `package_name: uz.stackyard.eld_mobile` + **release** imzo kalitining SHA-256 fingerprinti (`keytool -list -v -keystore upload.jks`) |
| iOS | `https://eld.stackyard.uz/.well-known/apple-app-site-association` | `applinks.details[].appID = <TEAM_ID>.uz.stackyard.eldMobile` (`Content-Type: application/json`, redirect'siz) |

iOS tomonda `ios/Runner/Runner.entitlements` da `applinks:eld.stackyard.uz` bor; Xcode'da
target Signing & Capabilities → **Associated Domains** yoqilgan bo'lishi kerak
(`CODE_SIGN_ENTITLEMENTS` build sozlamasi shu faylga ishora qiladi).
Fayllar joyiga qo'yilmaguncha `https` link brauzerda ochiladi — bu xavfsiz zaxira yo'l.

---

## 4. Build buyruqlari

```bash
# Ishga tayyorgarlik
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs

# Play uchun AAB (prod)
flutter build appbundle --release --dart-define-from-file=env/prod.json

# Ichki test uchun APK
flutter build apk --release --dart-define-from-file=env/stage.json

# iOS (arxiv)
cd ios && pod install && cd ..
flutter build ipa --release --dart-define-from-file=env/prod.json \
  --export-options-plist=ios/Runner/ExportOptions.plist
```

Chiqish: `build/app/outputs/bundle/release/app-release.aab` · `build/ios/ipa/*.ipa`.

Obfuskatsiya (crash simvollari bilan):
`--obfuscate --split-debug-info=build/symbols/<version>` → simvollarni Sentry/Play'ga yuklash shart.

---

## 5. Chiqarishdan oldingi checklist

- [ ] `flutter analyze` — 0 issue · `dart format --set-exit-if-changed` toza
- [ ] `flutter test` yashil · HOS golden vektorlar 35/35
- [ ] `flutter build apk --debug` va `flutter build appbundle --release` yashil
- [ ] `android/key.properties` mavjud, artefakt **release** kalit bilan imzolangan
      (`apksigner verify --print-certs` bilan tekshiring — CN debug bo'lmasin)
- [ ] `AndroidManifest.xml`: `allowBackup="false"`, `usesCleartextTraffic="false"`,
      `networkSecurityConfig` bor; ortiqcha ruxsat yo'q
- [ ] `Info.plist`: `NSAppTransportSecurity` da `NSAllowsArbitraryLoads=false`;
      barcha `NS*UsageDescription` matnlari aniq va sababi tushunarli
- [ ] `env/prod.json`: `ENABLE_DEV_MENU=false`, mock transport kompilyatsiyada yo'q (M163)
- [ ] `--dart-define=CERT_SPKI_PINS="<asosiy>,<zaxira>"` berilgan (§3.1); pinsiz prod build
      `StateError` bilan **ataylab** to'xtaydi
- [ ] `assetlinks.json` va `apple-app-site-association` serverda joyida (§3.2)
- [ ] Versiya `pubspec.yaml` da oshirilgan (§7 siyosati), CHANGELOG yozilgan
- [ ] Release notes (EN) tayyor

---

## 6. Rollback rejasi

**Android (Play):**
1. Staged rollout **1% → 10% → 50% → 100%**, har bosqich orasida ≥24 soat va crash-free ≥99.5%.
2. Muammo topilsa: Play Console → Release → **Halt rollout** (yangi foydalanuvchilarga tarqalish to'xtaydi).
3. Play'da "eski versiyaga qaytarish" **yo'q** — tuzatilgan `versionCode` bilan **hotfix** chiqariladi;
   shuning uchun oldingi barqaror teg (`v<x.y.z>`) doim yig'ilishga tayyor turadi.
4. Faqat oldingi versiyani qayta yoqish kerak bo'lsa: eski AAB'ni yangi `versionCode` bilan
   qayta yig'ib chiqarish (kod o'zgarmaydi, faqat build raqami).

**iOS (App Store):**
1. **Phased release** yoqilgan (7 kun). Muammoda → *Pause phased release*.
2. Kerak bo'lsa *Remove from sale* + oldingi versiyani **Expedited review** bilan qayta yuborish.

**Server tomoni:** mobil `v1` kontrakti muzlatilgan — mobil rollback backend deploy'ini talab qilmaydi.
Agar sabab sync bo'lsa, backend'da feature-flag bilan yangi maydon o'chiriladi (mobil oflayn ishlashda davom etadi).

**Kritik holat (ma'lumot yo'qolishi riski):** rollout darhol to'xtatiladi, outbox
formatiga tegilmaydi (Drift `schemaVersion` forward-only — pastga migratsiya YO'Q).

---

## 7. Versiyalash siyosati

`pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD`

- `MAJOR` — HOS hisoblash yoki sync protokoli buziladigan o'zgarish (backend CR bilan birga).
- `MINOR` — yangi ekran / funksiya.
- `PATCH` — tuzatish, xavfsizlik yamog'i.
- `BUILD` (`+N`) — **monoton o'suvchi butun son**, hech qachon qayta ishlatilmaydi.
  Android `versionCode` va iOS `CFBundleVersion` shundan olinadi. CI da build raqami
  qo'lda emas, `--build-number=$GITHUB_RUN_NUMBER` bilan beriladi.
- Git teg: `mobile-v<MAJOR>.<MINOR>.<PATCH>`; release branch: `release/mobile-<MAJOR>.<MINOR>`.

---

## 8. Store materiallari — ⏳ QOLGAN

Quyidagilar hali **tayyorlanmagan**, chiqarishdan oldin majburiy:

- [ ] ⏳ Ilova ikonkasi (Android adaptive 432×432 + monochrome, iOS 1024×1024) — hozir Flutter shabloni
- [ ] ⏳ Splash / launch screen (light + dark) — hozir shablon
- [ ] ⏳ Skrinshotlar: telefon × (light + dark) va planshet × (light + dark), har biri ≥4 ta
- [ ] ⏳ Feature graphic (1024×500, Play)
- [ ] ⏳ Ilova nomi, qisqa va to'liq tavsif (EN), kalit so'zlar
- [ ] ⏳ Maxfiylik siyosati URL (Play va App Store uchun majburiy)
- [ ] ⏳ **Play Data safety** formasi: joylashuv (aniq, fon), qurilma ID, fayllar (imzo/foto),
      shifrlash (TLS transit + SQLCipher at-rest), o'chirish so'rovi mexanizmi
- [ ] ⏳ **App Privacy (App Store)** "Nutrition label": Location (App Functionality, linked),
      Identifiers, User Content
- [ ] ⏳ **`ACCESS_BACKGROUND_LOCATION` deklaratsiyasi + demo video** (risk R1 — review 1–3 hafta;
      erta boshlanadi). Asosnoma: FMCSA 49 CFR §395.26 — ELD haydash paytida, ilova fonda
      bo'lganda ham, har o'zgarishda va har 60 daqiqada pozitsiya yozishi shart.
- [ ] ⏳ Play "Exact alarm" / "Full-screen intent" deklaratsiyalari — faqat B-46 da o'sha
      ruxsatlar qaytarilsa (hozir manifestdan olib tashlangan)
- [ ] ⏳ TestFlight ichki/tashqi test guruhlari va beta test ma'lumoti
- [ ] ⏳ Sertifikat pinning (M153) — 11-bosqich, store review'dan oldin

## 9. Foydalanuvchidan kerak bo'ladigan narsalar

- Google Play Console developer akkaunti (+ to'lov, D-U-N-S kerak emas)
- Apple Developer Program a'zoligi ($99/yil) va App Store Connect roli
- Upload keystore paroli / kalit egasi (yoki yaratishga ruxsat)
- Maxfiylik siyosati va foydalanuvchi shartnomasi matni (huquqiy)
- Qo'llab-quvvatlash email va veb-sayt URL (store listing uchun majburiy)
