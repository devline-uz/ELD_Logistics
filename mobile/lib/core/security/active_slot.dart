/// Faol haydovchi sloti — `core/network` va `features/auth` orasidagi ko'prik.
///
/// **M9:** kabinada ikkita mustaqil sessiya bo'ladi (`primary` + `co_driver`).
/// Har so'rov qaysi slot nomidan ketishini bilishi kerak, lekin `core/network`
/// `features/auth` ni ko'rmaydi (M5: qatlam qoidasi). Shu sababli faol slot
/// **shu yupqa holderda** turadi: `SessionManager` (features/auth) yozadi,
/// `SlotInterceptor` (core/network) o'qiydi.
///
/// Holder **holat manbai emas** — u faqat oxirgi qaror qilingan slotning
/// keshi. Haqiqiy sessiya holati `features/auth/domain/session_state.dart` da.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_vault.dart';

/// Faol slotni ushlab turuvchi mutable holder (`keepAlive` provayder).
class ActiveSlotHolder {
  ActiveSlotHolder([this.value = DriverSlot.primary]);

  /// `SessionManager` yozadi, `SlotInterceptor` o'qiydi.
  DriverSlot value;
}

/// Butun ilova uchun yagona holder.
final Provider<ActiveSlotHolder> activeSlotHolderProvider = Provider<ActiveSlotHolder>(
  (Ref ref) => ActiveSlotHolder(),
);
