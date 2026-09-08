/// `M-38 Begin inspection (kiosk rejimi)` [MUST] (tz-mobile 1427–1443).
///
/// Ekranda **faqat**: sana tasmasi (7 kun + bugun) · log grid · eventlar
/// jadvali · Log Form shapkasi. App bar, tab bar, drawer va back tugmasi
/// **yo'q** (`PopScope(canPop: false)`).
///
/// **M110:** hech narsa tahrirlanmaydi — faqat o'qish.
/// **M109:** rejimda push bildirishnoma ko'rsatilmaydi — bu qatlam
/// `core/notifications` ga tegmaydi, faqat [InspectionKioskScope] bayrog'ini
/// beradi (M10 da platforma kodi va push filtri unga ulanadi).
///
/// Platforma qulfi (Android lock task / iOS Guided Access) **M10 bosqichida**;
/// bu yerda faqat UI qatlami va chiqish PIN oqimi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/security/screen_protection.dart';
import '../../../../core/time/day_boundary.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/inspection_models.dart';
import '../controllers/inspection_controller.dart';
import '../widgets/exit_pin_dialog.dart';
import '../widgets/inspection_widgets.dart';

/// Kiosk rejimi faolligini bildiruvchi `InheritedWidget` (M109 uchun ilgak).
class InspectionKioskScope extends InheritedWidget {
  const InspectionKioskScope({required super.child, this.active = true, super.key});

  final bool active;

  static bool isActive(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InspectionKioskScope>()?.active ?? false;

  @override
  bool updateShouldNotify(InspectionKioskScope oldWidget) => oldWidget.active != active;
}

/// **M157 / #B-139:** `M-38` — `FLAG_SECURE` ro'yxatidagi ekran, shuning
/// uchun `ConsumerStatefulWidget`: [SecureScreenMixin] `initState` da
/// himoyani yoqadi va `dispose` da **majburiy** o'chiradi (aks holda butun
/// ilova skrinshotsiz qolib ketardi).
class InspectionKioskScreen extends ConsumerStatefulWidget {
  const InspectionKioskScreen({super.key});

  @override
  ConsumerState<InspectionKioskScreen> createState() => _InspectionKioskScreenState();
}

class _InspectionKioskScreenState extends ConsumerState<InspectionKioskScreen>
    with SecureScreenMixin<InspectionKioskScreen> {
  @override
  Widget build(BuildContext context) {
    final InspectionKioskState state = ref.watch(inspectionKioskControllerProvider);

    ref.listen<InspectionKioskState>(inspectionKioskControllerProvider, (
      InspectionKioskState? was,
      InspectionKioskState now,
    ) {
      // Sessiya muddati tugadi — rejim avtomatik yopiladi (PIN so'ralmaydi).
      if (now.expired && was?.expired != true && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    Future<void> exit() async {
      final bool ok = await showExitPinDialog(context);
      if (ok && context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    return InspectionKioskScope(
      child: PopScope<Object?>(
        // Android back tugmasi bloklanadi — chiqish faqat PIN orqali.
        canPop: false,
        child: Scaffold(
          backgroundColor: context.colors.bg,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenPaddingH(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _KioskTopBar(state: state, onExit: () => exit().ignore()),
                  Expanded(child: _KioskBody(state: state)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigatsiya emas — faqat `Exit` tugmasi va oflayn izohi.
class _KioskTopBar extends StatelessWidget {
  const _KioskTopBar({required this.state, required this.onExit});

  final InspectionKioskState state;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final InspectionReport? report = state.report;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.inspectionKioskTitle,
                  style: context.text.body11.copyWith(color: context.colors.textPrimary),
                ),
                Text(
                  report != null && report.isOffline
                      ? l10n.inspectionKioskOffline(
                          report.lastSyncedAt == null
                              ? l10n.inspectionKioskNeverSynced
                              : AppFormats.fullDateTime(report.lastSyncedAt),
                        )
                      : l10n.inspectionKioskReadOnly,
                  style: context.text.body16.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: AppButton.secondary(label: l10n.inspectionKioskExit, onPressed: onExit),
          ),
        ],
      ),
    );
  }
}

class _KioskBody extends ConsumerWidget {
  const _KioskBody({required this.state});

  final InspectionKioskState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 5),
      );
    }
    if (state.error != null) {
      return ErrorState(
        message: localizedInspectionError(l10n, state.error!),
        retryLabel: l10n.inspectionRetry,
        onRetry: () => ref.read(inspectionKioskControllerProvider.notifier).load().ignore(),
      );
    }
    if (state.isEmpty) {
      return EmptyState(
        title: l10n.inspectionEmpty,
        message: l10n.inspectionEmptyHint,
        icon: Icons.article_outlined,
      );
    }

    final InspectionReport report = state.report!;
    final InspectionDay? day = state.currentDay;
    if (day == null) {
      return EmptyState(
        title: l10n.inspectionKioskEmpty,
        message: l10n.inspectionEmptyHint,
        icon: Icons.article_outlined,
      );
    }

    final String timezone = day.timezone.isEmpty
        ? (report.timezone ?? kFallbackTimeZone)
        : day.timezone;

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.s20),
      children: <Widget>[
        DateStrip8Day(
          days: <DateStripDay>[
            for (final InspectionDay d in report.days)
              DateStripDay(
                date: d.date,
                certified: d.certification == InspectionCertification.certified,
              ),
          ],
          selected: day.date,
          onSelected: ref.read(inspectionKioskControllerProvider.notifier).selectDate,
        ),
        const SizedBox(height: Spacing.s15),
        InspectionDayGrid(day: day, dayStart: dayStartUtc(day.key, timezone)),
        const SizedBox(height: Spacing.s20),
        InspectionLogFormHeader(report: report, day: day),
        const SizedBox(height: Spacing.s20),
        Text(
          l10n.inspectionLogEvents,
          style: context.text.body11.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: Spacing.s10),
        if (day.events.isEmpty)
          EmptyState(
            title: l10n.inspectionKioskEmpty,
            message: l10n.inspectionEmptyHint,
            icon: Icons.article_outlined,
          )
        else
          InspectionEventsTable(events: day.events),
      ],
    );
  }
}
