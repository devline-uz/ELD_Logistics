/// HOS ko'rsatkichlari bloki — `M-09`, `M-12` va `M-15` uchun umumiy.
///
/// **M87:** telefonda 4 ta chiziqli indikator, planshetda 4 ta halqa.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/hos_snapshot.dart';

/// Bo'lim nomlari (`BREAK · DRIVE · SHIFT · CYCLE`) — ARB dan.
List<HosGaugeData> hosGauges(BuildContext context, HosSnapshot snapshot) {
  final AppLocalizations l10n = context.l10n;
  return <HosGaugeData>[
    HosGaugeData(
      bucket: HosBucket.breakTime,
      label: l10n.hosBucketBreak,
      remaining: snapshot.breakLeft,
      total: snapshot.breakTotal,
    ),
    HosGaugeData(
      bucket: HosBucket.drive,
      label: l10n.hosBucketDrive,
      remaining: snapshot.driveLeft,
      total: snapshot.driveTotal,
    ),
    HosGaugeData(
      bucket: HosBucket.shift,
      label: l10n.hosBucketShift,
      remaining: snapshot.shiftLeft,
      total: snapshot.shiftTotal,
    ),
    HosGaugeData(
      bucket: HosBucket.cycle,
      label: l10n.hosBucketCycle,
      remaining: snapshot.cycleLeft,
      total: snapshot.cycleTotal,
    ),
  ];
}

class HosIndicatorRow extends StatelessWidget {
  const HosIndicatorRow({required this.snapshot, this.ringDiameter = 96, super.key});

  final HosSnapshot snapshot;

  /// Planshet halqasining diametri.
  final double ringDiameter;

  @override
  Widget build(BuildContext context) {
    final List<HosGaugeData> gauges = hosGauges(context, snapshot);
    return AdaptiveView(
      phone: (BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final HosGaugeData gauge in gauges)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
              child: HosLinearIndicator(data: gauge),
            ),
        ],
      ),
      tablet: (BuildContext c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (final HosGaugeData gauge in gauges)
            HosRingIndicator(data: gauge, diameter: ringDiameter),
        ],
      ),
    );
  }
}
