/// `M-09` ning yuqori bloki (M88: scroll'siz ko'rinadigan qism).
///
/// Figma parite (`2177:12192`): kartalar `AppCard` (`#F6F6F6`, `r12`, pad 20),
/// status kartasi ichida **oq doira badge** + `10h 45m 32s` taymer, ostida
/// ajratuvchi + `⇄` va **ikonkali pill** status tugmalari, HOS bloki esa
/// 2×2 `HosCardGrid` (sarlavha o'ngida grid ↔ halqa almashtirgichi).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/presentation/widgets/hos_indicator_row.dart';
import '../../domain/home_models.dart';

/// Karta uchun umumiy qobiq — `AppCard` + ixtiyoriy sarlavha qatori.
class HomeCard extends StatelessWidget {
  const HomeCard({required this.child, this.title, this.trailing, this.divider = true, super.key});

  final Widget child;
  final String? title;
  final Widget? trailing;

  /// Sarlavha ostidagi ajratuvchi (Figma: HOS blokida yo'q).
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(title!, style: context.text.body11.copyWith(color: c.textPrimary)),
                ),
                ?trailing,
              ],
            ),
            if (divider)
              const Divider(height: Spacing.s20)
            else
              const SizedBox(height: Spacing.s15),
          ],
          child,
        ],
      ),
    );
  }
}

/// Sana + unit/haydovchi qatori (dizayn: `19 | Mon, November` · `1021 | ...`).
class HomeDateUnitCard extends StatelessWidget {
  const HomeDateUnitCard({required this.date, required this.driver, super.key});

  final DateTime date;
  final DriverContext driver;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return HomeCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: _Badged(
              badge: AppFormats.dayStripNumberOf(date),
              text: AppFormats.listHeaderOf(date),
            ),
          ),
          Container(width: Strokes.thin, height: Spacing.s40, color: c.stroke),
          Expanded(
            child: _Badged(
              badge: AppFormats.orNa(driver.unitNumber),
              text: <String>[
                if (driver.driverName.isNotEmpty) driver.driverName,
                if (driver.vehicleLabel.isNotEmpty) driver.vehicleLabel,
              ].join(', '),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badged extends StatelessWidget {
  const _Badged({required this.badge, required this.text});

  final String badge;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(Spacing.s10),
          decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
          child: Text(badge, style: context.text.body12.copyWith(color: c.textPrimary)),
        ),
        const SizedBox(width: Spacing.s10),
        Expanded(
          child: Text(
            AppFormats.orNa(text),
            style: context.text.body14.copyWith(color: c.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Joriy status + hisoblagich + status pill'lari.
///
/// Figma da **ikkita** pill (`SB`, `OFF`) bor, TZ M52 esa **uchtasini** talab
/// qiladi (`OFF · SB · ON`) — TZ Figma dan ustun (M2), shuning uchun uchta
/// pill chiziladi, lekin ko'rinishi Figma bo'yicha (qisqa yorliq + rangli
/// ikonka), yorliqlar kesilmaydi.
class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({
    required this.status,
    required this.special,
    required this.elapsed,
    required this.sleeperAvailable,
    required this.onSelected,
    this.onSwap,
    super.key,
  });

  final DutyStatusValue? status;
  final DutySpecial special;
  final Duration elapsed;
  final bool sleeperAvailable;
  final ValueChanged<DutyStatusValue> onSelected;

  /// `⇄` — co-driver almashtirish (M-20).
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final DutyStatusValue current = status ?? DutyStatusValue.off;
    final String label = switch (current) {
      DutyStatusValue.off => l10n.dutyStatusOffDuty,
      DutyStatusValue.sleeper => l10n.dutyStatusSleeper,
      DutyStatusValue.driving => l10n.dutyStatusDriving,
      DutyStatusValue.on => l10n.dutyStatusOnDuty,
    };
    final String specialLabel = switch (special) {
      DutySpecial.personalConveyance => l10n.dutyPersonalConveyance,
      DutySpecial.yardMove => l10n.dutyYardMove,
      DutySpecial.none => '',
    };

    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
            decoration: BoxDecoration(color: c.decoTeal, borderRadius: Radii.cardRadius),
            child: Column(
              children: <Widget>[
                // Figma: ikonka oq doira badge ichida.
                Container(
                  padding: const EdgeInsets.all(Spacing.s10),
                  decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
                  child: Icon(Icons.local_shipping, color: c.decoTeal, size: Spacing.s20),
                ),
                const SizedBox(height: Spacing.s10),
                Text(label, style: context.text.body11.copyWith(color: c.onPrimary)),
                if (specialLabel.isNotEmpty)
                  Text(specialLabel, style: context.text.body16.copyWith(color: c.onPrimary)),
                const SizedBox(height: Spacing.s5),
                Text(
                  homeElapsedLabel(l10n, elapsed),
                  style: context.text.body16.copyWith(
                    color: c.onPrimary,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.s15),
          _SwapDivider(onTap: onSwap, label: l10n.homeQuickCoDriver),
          const SizedBox(height: Spacing.s15),
          Row(
            children: <Widget>[
              for (final DutyStatusValue value in DutyStatusValue.selectable) ...<Widget>[
                Expanded(
                  child: _StatusPill(
                    label: homeStatusPillLabel(l10n, value),
                    icon: homeStatusIcon(value),
                    iconColor: homeStatusIconColor(c, value),
                    onPressed: value == DutyStatusValue.sleeper && !sleeperAvailable
                        ? null
                        : () => onSelected(value),
                  ),
                ),
                if (value != DutyStatusValue.selectable.last) const SizedBox(width: Spacing.s10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// `HH:mm:ss` o'rniga Figma formati — `10h 45m 32s` (§11.0.7 davomiylik).
String homeElapsedLabel(AppLocalizations l10n, Duration elapsed) {
  final Duration value = elapsed.isNegative ? Duration.zero : elapsed;
  String two(int n) => n.toString().padLeft(2, '0');
  return l10n.homeElapsedHms(
    two(value.inHours),
    two(value.inMinutes.remainder(60)),
    two(value.inSeconds.remainder(60)),
  );
}

/// Pill yorliqlari — Figma: `OFF`, `SB`, `ON` (kesilmaydi).
String homeStatusPillLabel(AppLocalizations l10n, DutyStatusValue value) => switch (value) {
  DutyStatusValue.off => l10n.homeStatusPillOff,
  DutyStatusValue.sleeper => l10n.homeStatusPillSb,
  DutyStatusValue.on => l10n.homeStatusPillOn,
  DutyStatusValue.driving => l10n.homeStatusPillDr,
};

IconData homeStatusIcon(DutyStatusValue value) => switch (value) {
  DutyStatusValue.off => Icons.power_settings_new,
  DutyStatusValue.sleeper => Icons.nightlight_round,
  DutyStatusValue.on => Icons.local_shipping,
  DutyStatusValue.driving => Icons.drive_eta,
};

/// Figma: `SB` — amber oy, `OFF` — qizil power (M81: ikkala temada bir xil).
Color homeStatusIconColor(AppColors c, DutyStatusValue value) => switch (value) {
  DutyStatusValue.off => c.primary,
  DutyStatusValue.sleeper => c.warning,
  DutyStatusValue.on => c.decoTeal,
  DutyStatusValue.driving => c.success,
};

/// Ajratuvchi chiziq + markazda `⇄` tugmasi.
class _SwapDivider extends StatelessWidget {
  const _SwapDivider({required this.onTap, required this.label});

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(height: Strokes.thin, color: c.stroke),
        ),
        Semantics(
          button: onTap != null,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s15),
              child: Icon(Icons.swap_horiz, size: Spacing.s20, color: c.textSecondary),
            ),
          ),
        ),
        Expanded(
          child: Container(height: Strokes.thin, color: c.stroke),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: c.surface,
        borderRadius: Radii.buttonRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: Radii.buttonRadius,
          child: Container(
            height: TouchTarget.phone,
            decoration: BoxDecoration(
              borderRadius: Radii.buttonRadius,
              border: Border.all(color: c.stroke, width: Strokes.thin),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: Spacing.s20, color: enabled ? iconColor : c.textDisabled),
                const SizedBox(width: Spacing.s5),
                Text(
                  label,
                  style: context.text.body13.copyWith(
                    color: enabled ? c.textPrimary : c.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `Hours of Service` kartasi — 2×2 karta grid, sarlavha o'ngida grid ↔ halqa
/// almashtirgichi (Figma `2177:12192`).
class HomeHosCard extends StatefulWidget {
  const HomeHosCard({required this.state, super.key});

  final HomeState state;

  @override
  State<HomeHosCard> createState() => _HomeHosCardState();
}

class _HomeHosCardState extends State<HomeHosCard> {
  bool _rings = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<HosGaugeData> gauges = hosGauges(context, widget.state.hos);
    return HomeCard(
      title: l10n.homeHoursOfService,
      divider: false,
      trailing: Semantics(
        button: true,
        label: l10n.homeHosToggleView,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _rings = !_rings),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.s5),
            child: Icon(Icons.swap_horiz, size: Spacing.s20, color: context.colors.textSecondary),
          ),
        ),
      ),
      child: _rings ? HosRingRow(gauges: gauges, diameter: 72) : HosCardGrid(gauges: gauges),
    );
  }
}

/// Tezkor amallar qatori (M87: `Inspection · Log Report · Co-driver · Leave Truck`).
///
/// Figma: to'rtta **alohida chegarali karta**, gorizontal scroll.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    required this.onInspection,
    required this.onLogReport,
    required this.onCoDriver,
    required this.onLeaveTruck,
    super.key,
  });

  final VoidCallback onInspection;
  final VoidCallback onLogReport;
  final VoidCallback onCoDriver;
  final VoidCallback onLeaveTruck;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _QuickAction(
            icon: Icons.assignment_outlined,
            label: l10n.homeQuickInspection,
            onTap: onInspection,
          ),
          _QuickAction(
            icon: Icons.description_outlined,
            label: l10n.homeQuickLogReport,
            onTap: onLogReport,
          ),
          _QuickAction(
            icon: Icons.people_alt_outlined,
            label: l10n.homeQuickCoDriver,
            onTap: onCoDriver,
          ),
          _QuickAction(icon: Icons.logout, label: l10n.homeQuickLeaveTruck, onTap: onLeaveTruck),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: Spacing.s10),
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: c.surface,
          borderRadius: Radii.cardRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: Radii.cardRadius,
            child: Container(
              width: 88,
              padding: const EdgeInsets.all(Spacing.s10),
              decoration: BoxDecoration(
                borderRadius: Radii.cardRadius,
                border: Border.all(color: c.stroke, width: Strokes.thin),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, color: c.icon, size: Spacing.s25),
                  const SizedBox(height: Spacing.s5),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.body16.copyWith(color: c.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
