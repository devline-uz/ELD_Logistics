/// `M-29 Certify (Last 8 days)` kontrolleri (M7: telefon + planshet umumiy).
///
/// Faqat **tanlov** holatini saqlaydi; kunlar oqimi `certifyWindowProvider`
/// dan keladi. Pastdagi tugma matni M124/§12.2 oqimiga qat'iy mos:
/// tanlov yo'q → `Certify All`, n kun → `Certify Selected (n)`,
/// faqat bugungi kun → `Certify Today`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/time_providers.dart';
import '../../domain/certify_models.dart';

/// Pastdagi asosiy tugmaning rejimi.
enum CertifyAction { all, selected, today, none }

class CertifyListState {
  const CertifyListState({this.selected = const <DateTime>{}});

  /// Tanlangan kunlar (kun aniqligida).
  final Set<DateTime> selected;

  CertifyListState copyWith({Set<DateTime>? selected}) =>
      CertifyListState(selected: selected ?? this.selected);
}

class CertifyListController extends Notifier<CertifyListState> {
  @override
  CertifyListState build() => const CertifyListState();

  DateTime get today {
    final DateTime now = ref.read(timeSourceProvider).now();
    return DateTime(now.year, now.month, now.day);
  }

  void toggle(CertifyDay day) {
    if (!day.selectable) {
      // M123: sertifikatlangan va `Not Ready` kunlar belgilanmaydi.
      return;
    }
    final Set<DateTime> next = <DateTime>{...state.selected};
    if (!next.remove(day.date)) {
      next.add(day.date);
    }
    state = state.copyWith(selected: next);
  }

  void selectAll(List<CertifyDay> days) => state = state.copyWith(
    selected: <DateTime>{
      for (final CertifyDay day in days)
        if (day.selectable) day.date,
    },
  );

  void clear() => state = state.copyWith(selected: const <DateTime>{});

  bool isSelected(CertifyDay day) => state.selected.contains(day.date);

  /// Ro'yxat ustidagi `Certify Today` qatori uchun bugungi kun (agar u
  /// sertifikatlanadigan bo'lsa). Aks holda qator ko'rsatilmaydi.
  CertifyDay? todayIn(List<CertifyDay> days) {
    final DateTime t = today;
    for (final CertifyDay day in days) {
      if (day.date == t && day.selectable) {
        return day;
      }
    }
    return null;
  }

  /// Tugma rejimi (§12.2).
  CertifyAction actionFor(List<CertifyDay> days) {
    if (state.selected.isEmpty) {
      final bool anySelectable = days.any((CertifyDay d) => d.selectable);
      return anySelectable ? CertifyAction.all : CertifyAction.none;
    }
    if (state.selected.length == 1 && state.selected.single == today) {
      return CertifyAction.today;
    }
    return CertifyAction.selected;
  }

  /// Imzoga yuboriladigan kunlar ro'yxati.
  List<DateTime> datesFor(List<CertifyDay> days) {
    if (state.selected.isNotEmpty) {
      return state.selected.toList()..sort();
    }
    return <DateTime>[
      for (final CertifyDay day in days)
        if (day.selectable) day.date,
    ]..sort();
  }
}

final NotifierProvider<CertifyListController, CertifyListState> certifyListControllerProvider =
    NotifierProvider<CertifyListController, CertifyListState>(CertifyListController.new);
