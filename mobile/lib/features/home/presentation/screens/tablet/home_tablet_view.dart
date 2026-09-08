/// `T-01 Home / Full screen` — planshetning uch ustunli asosiy ekrani.
///
/// Figma `1470:42666`. Layout aynan tz-mobile 1571–1596 dagi sxema bo'yicha:
/// ```
/// ┌ HOURS OF SERVICE │ DUTY STATUS        │ ACTIONS            ┐
/// │ 4 × HosRing      │ status + taymer    │ FMCSA / Inspection │
/// │                  │ status tugmalari   │ Co-driver          │
/// │                  │ TRIP DETAILS  [✎]  │ Leave Truck        │
/// │                  │                    │ CERTIFY Not Signed │
/// ├──────────────────┴────────────────────┴────────────────────┤
/// │ 24h LOG GRID + jami + Violation/Warning (ichki scroll)      │
/// └─────────────────────────────────────────────────────────────┘
/// ```
///
/// **M120 [MUST]:** ekran **scroll qilinmaydi** — 1366×1024 da hammasi
/// sig'adi; faqat log bloki ichki scroll'ga ega. Shuning uchun ustunlar
/// `Expanded` + `Flexible` bilan qurilgan, tashqi `ListView` yo'q.
///
/// **M121 [MUST]:** dizayndagi `Search Item ...` qidiruvi **olib tashlangan**.
///
/// **M7:** kontroller telefon bilan umumiy (`HomeController`) — bu yerda
/// biznes mantiq yo'q, faqat joylashuv.
library;

import 'package:flutter/material.dart';

import '../../../../../core/i18n/l10n_extension.dart';
import '../../../../../core/ui/ui.dart';
import '../../../../duty_status/domain/duty_status_models.dart';
import '../../../../duty_status/presentation/widgets/hos_indicator_row.dart';
import '../../../domain/home_models.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home_cards.dart';
import '../../widgets/home_log_cards.dart';

/// T-01 amallar paneli tugmalari (o'ng ustun).
class HomeTabletActions {
  const HomeTabletActions({
    required this.onInspection,
    required this.onCoDriver,
    required this.onLeaveTruck,
    required this.onCertify,
  });

  final VoidCallback onInspection;
  final VoidCallback onCoDriver;
  final VoidCallback onLeaveTruck;
  final VoidCallback onCertify;
}

class HomeTabletView extends StatelessWidget {
  const HomeTabletView({
    required this.state,
    required this.controller,
    required this.now,
    required this.actions,
    required this.onChangeStatus,
    required this.onEditDocuments,
    super.key,
  });

  final HomeState state;
  final HomeController controller;
  final DateTime now;
  final HomeTabletActions actions;
  final ValueChanged<DutyStatusValue> onChangeStatus;
  final VoidCallback onEditDocuments;

  /// Log bloki ekranning pastki ~35 % ini egallaydi (Figma proporsiyasi).
  static const int _topFlex = 62;
  static const int _logFlex = 38;

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 4),
      );
    }
    if (!state.hasUnit) {
      return EmptyState(
        title: context.l10n.homeNoUnitTitle,
        message: context.l10n.homeNoUnitMessage,
        icon: Icons.local_shipping_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: _topFlex,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 3, child: _HoursColumn(state: state)),
              const SizedBox(width: Spacing.s20),
              Expanded(
                flex: 5,
                child: _DutyColumn(
                  state: state,
                  now: now,
                  onChangeStatus: onChangeStatus,
                  onEditDocuments: onEditDocuments,
                ),
              ),
              const SizedBox(width: Spacing.s20),
              Expanded(
                flex: 4,
                child: _ActionsColumn(state: state, actions: actions),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.s15),
        // Yagona scroll qiladigan blok (M120).
        Expanded(
          flex: _logFlex,
          child: SingleChildScrollView(child: HomeLogCard(state: state)),
        ),
      ],
    );
  }
}

/// Chap ustun — `HOURS OF SERVICE`, 4 ta `HosRingIndicator`.
///
/// **M120:** ustun scroll qilinmaydi, shuning uchun halqa diametri mavjud
/// balandlikdan hisoblanadi va [_minRing]…[_maxRing] oralig'iga qisiladi.
/// Bu 1366×1024 dan tashqari o'lchamlarda ham (masalan 1280×800 planshet)
/// overflow bo'lmasligini kafolatlaydi.
class _HoursColumn extends StatelessWidget {
  const _HoursColumn({required this.state});

  final HomeState state;

  /// Halqa + yorliq + oraliq (`Spacing.s10` + `body14`).
  static const double _labelBlock = 34;
  static const double _minRing = 64;
  static const double _maxRing = 120;

  @override
  Widget build(BuildContext context) => HomeCard(
    title: context.l10n.homeHoursOfService,
    child: Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final List<HosGaugeData> gauges = hosGauges(context, state.hos);
          final double slot = constraints.maxHeight / gauges.length;
          final double diameter = (slot - _labelBlock).clamp(_minRing, _maxRing);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (final HosGaugeData gauge in gauges)
                HosRingIndicator(data: gauge, diameter: diameter),
            ],
          );
        },
      ),
    ),
  );
}

/// O'rta ustun — `DUTY STATUS` va `TRIP DETAILS`.
class _DutyColumn extends StatelessWidget {
  const _DutyColumn({
    required this.state,
    required this.now,
    required this.onChangeStatus,
    required this.onEditDocuments,
  });

  final HomeState state;
  final DateTime now;
  final ValueChanged<DutyStatusValue> onChangeStatus;
  final VoidCallback onEditDocuments;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Flexible(
        child: HomeStatusCard(
          status: state.duty.current,
          special: state.duty.special,
          elapsed: state.duty.since == null ? Duration.zero : now.difference(state.duty.since!),
          sleeperAvailable: state.duty.sleeperAvailable,
          onSelected: onChangeStatus,
        ),
      ),
      const SizedBox(height: Spacing.s15),
      Flexible(
        child: HomeTripCard(trip: state.trip, onEdit: onEditDocuments),
      ),
    ],
  );
}

/// O'ng ustun — `ACTIONS` paneli va `CERTIFY` kartasi.
class _ActionsColumn extends StatelessWidget {
  const _ActionsColumn({required this.state, required this.actions});

  final HomeState state;
  final HomeTabletActions actions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HomeCard(
          title: l10n.homeActionsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppButton.secondary(label: l10n.homeFmcsaInspection, onPressed: actions.onInspection),
              const SizedBox(height: Spacing.s10),
              AppButton.secondary(label: l10n.homeQuickCoDriver, onPressed: actions.onCoDriver),
              const SizedBox(height: Spacing.s10),
              AppButton.secondary(label: l10n.authLeaveTruckTitle, onPressed: actions.onLeaveTruck),
            ],
          ),
        ),
        const SizedBox(height: Spacing.s15),
        Flexible(
          child: HomeCertifyCard(days: state.certifyDays, onTap: actions.onCertify),
        ),
      ],
    );
  }
}
