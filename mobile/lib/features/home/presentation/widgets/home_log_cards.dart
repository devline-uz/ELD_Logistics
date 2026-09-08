/// `M-09` ning scroll ostidagi bloklari: Trip Details, Certify, sariq
/// kartalar va 24 soatlik log bloki.
library;

import 'package:flutter/material.dart';
import 'package:hos_engine/hos_engine.dart';

import '../../../../core/hos/violation_labels.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/domain/hos_snapshot.dart';
import '../../domain/home_models.dart';
import 'home_cards.dart';

/// `Trip Details` — `Shipping Document · Trailer Number · Notes` (+ `M-11`).
class HomeTripCard extends StatelessWidget {
  const HomeTripCard({required this.trip, required this.onEdit, super.key});

  final TripDetails trip;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return HomeCard(
      title: l10n.homeTripDetails,
      trailing: IconButton(
        tooltip: l10n.homeEditDocuments,
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined),
      ),
      child: Column(
        children: <Widget>[
          _TripRow(
            icon: Icons.description_outlined,
            label: l10n.documentsShippingDocument,
            value: trip.shippingDocs.join(', '),
          ),
          _TripRow(
            icon: Icons.local_shipping_outlined,
            label: l10n.documentsTrailerNumber,
            value: trip.trailers.join(', '),
          ),
          _TripRow(icon: Icons.notes_outlined, label: l10n.dutyNotesLabel, value: trip.notes),
        ],
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  const _TripRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: Spacing.s20, color: c.textSecondary),
          const SizedBox(width: Spacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: context.text.body14.copyWith(color: c.textSecondary)),
                Text(
                  AppFormats.orNa(value),
                  style: context.text.body13.copyWith(color: c.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `Signature` / `Certify (Last 8 days)` kartasi.
class HomeCertifyCard extends StatelessWidget {
  const HomeCertifyCard({required this.days, required this.onTap, super.key});

  final List<CertifyDay> days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return HomeCard(
      title: l10n.homeSignature,
      trailing: IconButton(
        tooltip: l10n.homeCertifyLast8Days,
        onPressed: onTap,
        icon: const Icon(Icons.edit_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.draw_outlined, size: Spacing.s20, color: c.textSecondary),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: Text(
                  l10n.homeCertifyLast8Days,
                  style: context.text.body14.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s10),
          Row(
            children: <Widget>[
              for (final CertifyDay day in days)
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.s10),
                  child: Semantics(
                    label: AppFormats.dayStripOf(day.date),
                    child: Icon(
                      Icons.circle,
                      size: Spacing.s15,
                      color: day.certified ? c.success : c.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sariq shartli karta (`Pending edits`, `Unidentified driving`).
class HomeAlertCard extends StatelessWidget {
  const HomeAlertCard({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(Spacing.cardPadding),
          decoration: BoxDecoration(
            color: c.warningBg,
            borderRadius: Radii.cardRadius,
            border: Border.all(color: c.warning, width: Strokes.thin),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.warning_amber_outlined, color: c.warningDark),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: Text(label, style: context.text.body13.copyWith(color: c.warningDark)),
              ),
              Icon(Icons.chevron_right, color: c.warningDark),
            ],
          ),
        ),
      ),
    );
  }
}

/// 24 soatlik grid + kunlik jami + violation satrlari.
class HomeLogCard extends StatelessWidget {
  const HomeLogCard({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return HomeCard(
      title: l10n.homeLogsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DutyGrid24h(
              segments: <DutySegment>[
                for (final DutyDaySegment segment in state.segments)
                  DutySegment(
                    slot: _slotOf(segment.status),
                    start: segment.start,
                    end: segment.end,
                  ),
              ],
              rowLabels: <DutySlot, String>{
                DutySlot.offDuty: l10n.homeTotalOff,
                DutySlot.sleeper: l10n.homeTotalSb,
                DutySlot.driving: l10n.homeTotalDrive,
                DutySlot.onDuty: l10n.homeTotalOn,
              },
            ),
          ),
          const SizedBox(height: Spacing.s10),
          Wrap(
            spacing: Spacing.s10,
            runSpacing: Spacing.s5,
            children: <Widget>[
              _Total(label: l10n.homeTotalOff, value: state.hos.totals.off, slot: DutySlot.offDuty),
              _Total(label: l10n.homeTotalSb, value: state.hos.totals.sb, slot: DutySlot.sleeper),
              _Total(
                label: l10n.homeTotalDrive,
                value: state.hos.totals.drive,
                slot: DutySlot.driving,
              ),
              _Total(label: l10n.homeTotalOn, value: state.hos.totals.on, slot: DutySlot.onDuty),
            ],
          ),
          const SizedBox(height: Spacing.s10),
          if (state.hos.violations.isEmpty)
            Text(l10n.homeNoViolations, style: context.text.body14.copyWith(color: c.textSecondary))
          else
            for (final HosViolation violation in state.hos.violations)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.s5),
                child: Text(
                  '${violation.severity == Severity.violation ? l10n.homeViolationLabel : l10n.homeWarningLabel} '
                  '${violationTypeLabel(l10n, violation.type)}',
                  style: context.text.body14.copyWith(
                    color: violation.severity == Severity.violation ? c.error : c.warningDark,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static DutySlot _slotOf(DutyStatusValue status) => switch (status) {
    DutyStatusValue.off => DutySlot.offDuty,
    DutyStatusValue.sleeper => DutySlot.sleeper,
    DutyStatusValue.driving => DutySlot.driving,
    DutyStatusValue.on => DutySlot.onDuty,
  };
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, required this.slot});

  final String label;
  final Duration value;
  final DutySlot slot;

  @override
  Widget build(BuildContext context) => Text(
    '$label ${AppFormats.durationHm(value)}',
    style: context.text.body16.copyWith(color: context.colors.dutyColor(slot)),
  );
}
