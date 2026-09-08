/// `outbox_items.session_slot` ustuni bilan [DriverSlot] orasidagi ko'prik
/// (**B-120 / B-121**, tz-mobile §3.3).
///
/// `sync_core` sof Dart — u `DriverSlot` ni ko'rmaydi va slotni oddiy `int`
/// sifatida biladi. Ilova qatlamida esa token, refresh mutexi va interceptor
/// `DriverSlot` bilan ishlaydi. Ikki tomonni **faqat shu fayl** bog'laydi,
/// shuning uchun `0`/`1` sehrli raqamlari boshqa hech qayerda uchramaydi.
library;

import 'package:sync_core/sync_core.dart';

import '../security/secure_vault.dart';

/// Slotning DB ustunidagi qiymati.
int slotColumn(DriverSlot slot) => slot == DriverSlot.coDriver ? kCoDriverSlot : kPrimarySlot;

/// DB ustunidan slotni tiklaydi. Noma'lum qiymat — `primary` (fail-safe:
/// yozuv yo'qolmaydi, faqat asosiy sessiya nomidan ketadi).
DriverSlot slotFromColumn(int value) =>
    value == kCoDriverSlot ? DriverSlot.coDriver : DriverSlot.primary;

/// Slotda tirik sessiya (refresh token) bor-yo'qligini bildiruvchi zond.
///
/// Push ishchisi shu zond `true` degan slotlarnigina yuboradi; qolganlarining
/// navbati **saqlanadi** (M17/M23 — 0 event yo'qotish).
typedef SlotTokenProbe = Future<bool> Function(DriverSlot slot);

/// Zondning standart implementatsiyasi: `SecureVault` dagi refresh token.
///
/// Refresh token secure storage'da yotadi, shuning uchun `paused` (Leave
/// Truck) slot ham «tokeni bor» hisoblanadi — co-driver pauzada bo'lsa ham
/// uning navbati yuboriladi (B-120 talabi).
SlotTokenProbe vaultSlotTokenProbe(SecureVault vault) =>
    (DriverSlot slot) async => (await vault.readRefreshToken(slot))?.isNotEmpty ?? false;

/// Zondni barcha slotlar bo'yicha yuritadi va ruxsat etilgan ustun
/// qiymatlarini qaytaradi.
Future<Set<int>> resolveAllowedSlots(SlotTokenProbe probe) async {
  final Set<int> allowed = <int>{};
  for (final DriverSlot slot in DriverSlot.values) {
    if (await probe(slot)) {
      allowed.add(slotColumn(slot));
    }
  }
  return allowed;
}
