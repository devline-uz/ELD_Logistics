/// Katalog ekrani uchun preview bloklari (faqat debug).
///
/// Golden testlar ham shu bloklardan foydalanadi — katalog va golden bir xil
/// ma'lumotni ko'rsatadi. Matnlar token/komponent nomlari (`// i18n-exempt`).
library;

import 'package:flutter/material.dart';

import '../../core/ui/ui.dart';

/// Rang palitrasi: neutral 1…11, state, decorative, HOS.
class ColorsPreview extends StatelessWidget {
  const ColorsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Swatches(
          label: 'Neutral 1…11', // i18n-exempt
          colors: AppPalette.neutrals,
        ),
        const SizedBox(height: Spacing.s10),
        _Swatches(
          label: 'State', // i18n-exempt
          colors: <Color>[
            c.successBg,
            c.success,
            c.successDark,
            c.warningBg,
            c.warning,
            c.warningDark,
            c.errorBg,
            c.error,
            c.errorDark,
          ],
        ),
        const SizedBox(height: Spacing.s10),
        const _Swatches(
          label: 'Decorative', // i18n-exempt
          colors: AppPalette.decoratives,
        ),
        const SizedBox(height: Spacing.s10),
        _Swatches(
          label: 'HOS', // i18n-exempt
          colors: <Color>[c.hosBreak, c.hosDrive, c.hosShift, c.hosCycle],
        ),
        const SizedBox(height: Spacing.s10),
        _Swatches(
          label: 'Surfaces', // i18n-exempt
          colors: <Color>[c.bg, c.surface, c.surfaceAlt, c.surfaceMuted, c.sidebar, c.stroke],
        ),
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.label, required this.colors});

  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: context.text.body14.copyWith(color: context.colors.textSecondary)),
      const SizedBox(height: Spacing.s5),
      Wrap(
        spacing: Spacing.s5,
        runSpacing: Spacing.s5,
        children: <Widget>[
          for (final Color color in colors)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: Radii.cardRadius,
                border: Border.all(color: context.colors.stroke, width: Strokes.thin),
              ),
            ),
        ],
      ),
    ],
  );
}

/// 23 ta nomlangan matn tokeni.
class TypographyPreview extends StatelessWidget {
  const TypographyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final MapEntry<String, TextStyle> e in AppTypography.all.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                SizedBox(
                  width: 72,
                  child: Text(e.key, style: context.text.body16.copyWith(color: c.textSecondary)),
                ),
                Expanded(
                  child: Text(
                    'OneBook ELD', // i18n-exempt
                    style: e.value.copyWith(color: c.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Namuna HOS ma'lumoti — telefon va planshet uchun bir xil.
List<HosGaugeData> demoHosGauges() => <HosGaugeData>[
  const HosGaugeData(
    bucket: HosBucket.breakTime,
    label: 'BREAK', // i18n-exempt
    remaining: Duration(hours: 7, minutes: 15),
    total: Duration(hours: 8),
  ),
  const HosGaugeData(
    bucket: HosBucket.drive,
    label: 'DRIVE', // i18n-exempt
    remaining: Duration(hours: 8, minutes: 30),
    total: Duration(hours: 11),
  ),
  const HosGaugeData(
    bucket: HosBucket.shift,
    label: 'SHIFT', // i18n-exempt
    remaining: Duration(hours: 11, minutes: 5),
    total: Duration(hours: 14),
  ),
  const HosGaugeData(
    bucket: HosBucket.cycle,
    label: 'CYCLE', // i18n-exempt
    remaining: Duration(hours: 41, minutes: 20),
    total: Duration(hours: 70),
  ),
];

class HosLinearPreview extends StatelessWidget {
  const HosLinearPreview({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (final HosGaugeData g in demoHosGauges())
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.s10),
          child: HosLinearIndicator(data: g),
        ),
    ],
  );
}

class HosRingPreview extends StatelessWidget {
  const HosRingPreview({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.s20,
    runSpacing: Spacing.s20,
    children: <Widget>[for (final HosGaugeData g in demoHosGauges()) HosRingIndicator(data: g)],
  );
}

/// Namuna kun: OFF → ON → D → OFF → SB.
List<DutySegment> demoDutySegments() => const <DutySegment>[
  DutySegment(slot: DutySlot.offDuty, start: Duration(), end: Duration(hours: 6)),
  DutySegment(slot: DutySlot.onDuty, start: Duration(hours: 6), end: Duration(hours: 7)),
  DutySegment(slot: DutySlot.driving, start: Duration(hours: 7), end: Duration(hours: 12)),
  DutySegment(
    slot: DutySlot.offDuty,
    start: Duration(hours: 12),
    end: Duration(hours: 12, minutes: 45),
  ),
  DutySegment(
    slot: DutySlot.driving,
    start: Duration(hours: 12, minutes: 45),
    end: Duration(hours: 18),
  ),
  DutySegment(slot: DutySlot.sleeper, start: Duration(hours: 18), end: Duration(hours: 24)),
];

const Map<DutySlot, String> demoDutyLabels = <DutySlot, String>{
  DutySlot.offDuty: 'OFF', // i18n-exempt
  DutySlot.sleeper: 'SB', // i18n-exempt
  DutySlot.driving: 'D', // i18n-exempt
  DutySlot.onDuty: 'ON', // i18n-exempt
};

class DutyGridPreview extends StatelessWidget {
  const DutyGridPreview({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DutyGrid24h(segments: demoDutySegments(), rowLabels: demoDutyLabels),
  );
}

/// 8 kunlik namuna (2025-05-14 … 2025-05-21, UTC — deterministik golden).
List<DateStripDay> demoDays() => <DateStripDay>[
  for (int i = 0; i < 8; i++)
    DateStripDay(date: DateTime.utc(2025, 5, 14 + i), certified: i < 5, hasViolation: i == 6),
];

class DateStripPreview extends StatelessWidget {
  const DateStripPreview({required this.selected, required this.onSelected, super.key});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) =>
      DateStrip8Day(days: demoDays(), selected: selected, onSelected: onSelected);
}
