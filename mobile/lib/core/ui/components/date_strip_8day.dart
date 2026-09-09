/// `DateStrip8Day` — 8 kunlik sana tasmasi (tz-mobile §11.0.4, §11.0.7).
///
/// Figma parite (#B-16): karta **60×80**, `r10`, fon `surfaceMuted`, oraliq 10;
/// **ikki qator** — hafta kuni (`EEE`, `textSecondary`) va kun raqami (`dd`).
/// Faol karta `primary` fon + oq matn. Sertifikatlanmagan kun ostida `warning`
/// nuqta, buzilish bo'lsa `error` (M91/M92 · `intl` + `en_US`).
library;

import 'dart:async';

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

/// Karta o'lchami — Figma 60×80 (#B-16).
const double kDateStripItemWidth = 60;
const double kDateStripItemHeight = 80;

class DateStrip8Day extends StatefulWidget {
  const DateStrip8Day({
    required this.days,
    required this.selected,
    required this.onSelected,
    this.itemWidth = kDateStripItemWidth,
    super.key,
  });

  /// Odatda 8 ta kun (eng eskisi birinchi).
  final List<DateStripDay> days;

  /// Tanlangan kun (kun aniqligida solishtiriladi).
  final DateTime selected;

  final ValueChanged<DateTime> onSelected;

  final double itemWidth;

  @override
  State<DateStrip8Day> createState() => _DateStrip8DayState();
}

class _DateStrip8DayState extends State<DateStrip8Day> {
  /// Figma `r10` (#B-16).
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(Radii.navChip));

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _revealSelected(animate: false));
  }

  @override
  void didUpdateWidget(DateStrip8Day old) {
    super.didUpdateWidget(old);
    if (!_isSame(old.selected, widget.selected) || old.days.length != widget.days.length) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tanlangan kunni ko'rinadigan hududga olib keladi: 8 kun 393 dp ga
  /// sig'maydi, shuning uchun faol karta markazga yaqinlashtiriladi.
  void _revealSelected({bool animate = true}) {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    final int index = widget.days.indexWhere((DateStripDay d) => _isSame(d.date, widget.selected));
    if (index < 0) {
      return;
    }
    final double step = widget.itemWidth + Spacing.s10;
    final double viewport = _controller.position.viewportDimension;
    final double target = (index * step - (viewport - widget.itemWidth) / 2).clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );
    if ((target - _controller.offset).abs() < 1) {
      return;
    }
    if (animate) {
      unawaited(
        _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  bool _isSame(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<DateStripDay> days = widget.days;

    return SizedBox(
      height: kDateStripItemHeight,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: Spacing.s10),
        itemBuilder: (BuildContext context, int index) {
          final DateStripDay day = days[index];
          final bool active = _isSame(day.date, widget.selected);
          final Color? dot = day.hasViolation ? c.error : (day.certified ? null : c.warning);

          return Semantics(
            selected: active,
            button: true,
            child: Material(
              color: active ? c.primary : c.surfaceMuted,
              borderRadius: _radius,
              child: InkWell(
                onTap: () => widget.onSelected(day.date),
                borderRadius: _radius,
                child: Ink(
                  width: widget.itemWidth,
                  decoration: const BoxDecoration(borderRadius: _radius),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppFormats.dayStripWeekdayOf(day.date),
                        style: context.text.body16.copyWith(
                          color: active ? c.onPrimary : c.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.s5 / 2),
                      Text(
                        AppFormats.dayStripNumberOf(day.date),
                        style: context.text.body12.copyWith(
                          color: active ? c.onPrimary : c.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.s5 / 2),
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
