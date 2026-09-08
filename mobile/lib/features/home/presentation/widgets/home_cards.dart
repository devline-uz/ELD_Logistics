/// `M-09` ning yuqori bloki (M88: scroll'siz ko'rinadigan qism).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/presentation/widgets/hos_indicator_row.dart';
import '../../domain/home_models.dart';

/// Karta uchun umumiy qobiq (fon `surface`, radius `Radii.card`).
class HomeCard extends StatelessWidget {
  const HomeCard({required this.child, this.title, this.trailing, super.key});

  final Widget child;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.cardGap),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(color: c.surface, borderRadius: Radii.cardRadius),
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
            const Divider(height: Spacing.s20),
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
            child: _Badged(badge: date.day.toString(), text: AppFormats.listHeaderOf(date)),
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
          decoration: BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
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

/// Joriy status + hisoblagich + **uchta** status tugmasi (M52).
class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({
    required this.status,
    required this.special,
    required this.elapsed,
    required this.sleeperAvailable,
    required this.onSelected,
    super.key,
  });

  final DutyStatusValue? status;
  final DutySpecial special;
  final Duration elapsed;
  final bool sleeperAvailable;
  final ValueChanged<DutyStatusValue> onSelected;

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
                Icon(Icons.local_shipping_outlined, color: c.onPrimary, size: Spacing.s30),
                const SizedBox(height: Spacing.s5),
                Text(label, style: context.text.body2.copyWith(color: c.onPrimary)),
                if (specialLabel.isNotEmpty)
                  Text(specialLabel, style: context.text.body16.copyWith(color: c.onPrimary)),
                Text(
                  AppFormats.durationHms(elapsed),
                  style: context.text.body12.copyWith(
                    color: c.onPrimary,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.s15),
          Row(
            children: <Widget>[
              for (final DutyStatusValue value in DutyStatusValue.selectable) ...<Widget>[
                Expanded(
                  child: AppButton.secondary(
                    label: switch (value) {
                      DutyStatusValue.off => l10n.dutyStatusOffDuty,
                      DutyStatusValue.sleeper => l10n.dutyStatusSleeper,
                      DutyStatusValue.on => l10n.dutyStatusOnDuty,
                      DutyStatusValue.driving => l10n.dutyStatusDriving,
                    },
                    onPressed: value == DutyStatusValue.sleeper && !sleeperAvailable
                        ? null
                        : () => onSelected(value),
                  ),
                ),
                if (value != DutyStatusValue.selectable.last) const SizedBox(width: Spacing.s5),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// `Hours of Service` kartasi — telefonda 4 chiziq, planshetda 4 halqa (M87).
class HomeHosCard extends StatelessWidget {
  const HomeHosCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) => HomeCard(
    title: context.l10n.homeHoursOfService,
    child: HosIndicatorRow(snapshot: state.hos),
  );
}

/// Tezkor amallar qatori (M87: `Inspection · Log Report · Co-driver · Leave Truck`).
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
      height: 96,
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
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.cardRadius,
          child: Container(
            width: 96,
            padding: const EdgeInsets.all(Spacing.s10),
            decoration: BoxDecoration(color: c.surface, borderRadius: Radii.cardRadius),
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
    );
  }
}
