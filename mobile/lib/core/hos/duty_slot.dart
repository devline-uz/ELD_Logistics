/// `hos_engine` duty statusi → `core/ui` grid slot'i (yagona adapter).
///
/// **#B-30/#B-31:** `DutyStatus` ning yagona manbai — muzlatilgan
/// `packages/hos_engine`. Modullar (`logs`, `inspection`, `home`, …) o'z
/// nusxasini yasamaydi: Go ↔ Dart pariteti (A1) faqat bitta enum bilan
/// saqlanadi, mapping esa faqat shu yerda.
library;

import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../ui/ui.dart' show DutySlot;

/// Duty status → 24 soatlik grid qatori.
DutySlot dutySlotOf(DutyStatus status) => switch (status) {
  DutyStatus.off => DutySlot.offDuty,
  DutyStatus.sb => DutySlot.sleeper,
  DutyStatus.dr => DutySlot.driving,
  DutyStatus.on => DutySlot.onDuty,
};
