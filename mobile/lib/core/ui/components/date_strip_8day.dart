/// `DateStrip8Day` — 8 kunlik sana tasmasi (tz-mobile §11.0.4, §11.0.7).
///
/// Format `EEE dd` (`Fri 07`, M91/M92 · `intl` + `en_US`). Faol kun `primary`
/// fon + oq matn, radius 12. Sertifikatlanmagan kun ostida `warning` nuqta.
library;

import 'package:flutter/material.dart';

import '../formats.dart';
import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Bitta kun elementi.
@immutable
class DateStripDay {
  const DateStripDay({required this.date, this.certified = true, this.hasViolation = false});

  final DateTime date;

  /// `false` — sertifikatlanmagan (warning nuqta).
  final bool certified;

  /// `true` — buzilish bor (error nuqta ustunroq).
  final bool hasViolation;
}

class DateStrip8Day extends StatelessWidget {
  const DateStrip8Day({
    required this.days,
    required this.selected,
    required this.onSelected,
    this.itemWidth = 56,
    super.key,
  });

  /// Odatda 8 ta kun (eng eskisi birinchi).
  final List<DateStripDay> days;

  /// Tanlangan kun (kun aniqligida solishtiriladi).
  final DateTime selected;

  final ValueChanged<DateTime> onSelected;

  final double itemWidth;

  bool _isSame(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.s5),
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: Spacing.s5),
        itemBuilder: (BuildContext context, int index) {
          final DateStripDay day = days[index];
          final bool active = _isSame(day.date, selected);
          final Color? dot = day.hasViolation ? c.error : (day.certified ? null : c.warning);

          return Semantics(
            selected: active,
            button: true,
            child: Material(
              color: active ? c.primary : c.surface,
              borderRadius: Radii.buttonRadius,
              child: InkWell(
                onTap: () => onSelected(day.date),
                borderRadius: Radii.buttonRadius,
                child: Ink(
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: Radii.buttonRadius,
                    border: Border.all(color: active ? c.primary : c.stroke, width: Strokes.thin),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppFormats.dayStripOf(day.date),
                        style: context.text.body14.copyWith(
                          color: active ? c.onPrimary : c.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.s5),
                      Container(
                        width: Spacing.s5,
                        height: Spacing.s5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dot ?? c.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
