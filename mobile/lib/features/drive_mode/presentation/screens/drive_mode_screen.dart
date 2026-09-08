/// `M-15 Drive mode (focused)` (`/drive`, Figma `1170:2684`).
///
/// Ekran to'liq band bo'ladi: chat, DVIR, sertifikatsiya va sozlamalar
/// bloklanadi (M58). Ruxsat: `Off Duty` / `On Duty` ga o'tish, PC/YM,
/// idle so'roviga javob. Ekran **avtomatik yopilmaydi** (M59).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/location/location_models.dart';
import '../../../../core/location/location_providers.dart';
import '../../../../core/ui/ui.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/domain/hos_snapshot.dart';
import '../controllers/drive_mode_controller.dart';
import '../widgets/drive_timer_ring.dart';
import '../widgets/idle_prompt_dialog.dart';

class DriveModeScreen extends ConsumerWidget {
  const DriveModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DriveModeState state = ref.watch(driveModeControllerProvider);
    final DriveModeController controller = ref.read(driveModeControllerProvider.notifier);
    final DateTime now =
        ref.watch(secondTickProvider).value ?? state.statusSince ?? DateTime.utc(2000);
    final HosSnapshot snapshot = ref.watch(hosSnapshotProvider).value ?? HosSnapshot.empty(now);
    final GeocodedPlace? place = ref.watch(currentPlaceProvider).value;

    final Widget body = _DriveBody(
      state: state,
      controller: controller,
      snapshot: snapshot,
      now: now,
      locationLabel: place?.label,
    );

    return Scaffold(
      backgroundColor: context.colors.bg,
      // Figma `1170:2684`: app bar faqat sarlavha, harakat guruhi yo'q.
      // M58: haydash rejimida chat/bildirishnoma kirishi bloklanadi — standart
      // amallar (bell/mail/refresh) shu sabab o'chirilgan.
      appBar: AppBarPrimary(title: l10n.driveTitle, showDefaultActions: false),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenPaddingH(context)),
              child: body,
            ),
            if (state.promptVisible)
              IdlePromptOverlay(
                onStillDriving: controller.answerStillDriving,
                onNotDriving: controller.answerNotDriving,
              ),
          ],
        ),
      ),
    );
  }
}

class _DriveBody extends StatelessWidget {
  const _DriveBody({
    required this.state,
    required this.controller,
    required this.snapshot,
    required this.now,
    required this.locationLabel,
  });

  final DriveModeState state;
  final DriveModeController controller;
  final HosSnapshot snapshot;
  final DateTime now;
  final String? locationLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final Duration elapsed = state.statusSince == null
        ? Duration.zero
        : now.difference(state.statusSince!);
    final double progress = snapshot.driveTotal.inSeconds == 0
        ? 0
        : snapshot.driveLeft.inSeconds / snapshot.driveTotal.inSeconds;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.circle,
                    size: Spacing.s10,
                    color: state.inMotion ? c.hosDrive : c.textSecondary,
                  ),
                  const SizedBox(width: Spacing.s5),
                  Flexible(
                    child: Text(
                      state.inMotion ? l10n.driveInMotion : l10n.driveStopped,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.body13.copyWith(color: c.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.s10),
            Flexible(
              child: Text(
                AppFormats.fullDateTime(now),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: context.text.body13.copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.s40),
        Center(
          child: DriveTimerRing(
            elapsed: elapsed,
            label: l10n.hosBucketDrive,
            progress: progress,
            color: c.hosDrive,
            diameter: adaptiveValue<double>(context, phone: 240, tablet: 320),
          ),
        ),
        const SizedBox(height: Spacing.s20),
        Container(
          padding: const EdgeInsets.all(Spacing.cardPadding),
          decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: Radii.cardRadius),
          child: Column(
            children: <Widget>[
              _InfoRow(
                label: l10n.driveDrivingTimeLeft,
                value: AppFormats.durationHms(snapshot.drivingTimeLeft),
              ),
              const SizedBox(height: Spacing.s10),
              _InfoRow(label: l10n.driveCurrentLocation, value: AppFormats.orNa(locationLabel)),
            ],
          ),
        ),
        const SizedBox(height: Spacing.s25),
        // M58: haydash rejimida faqat `Off Duty` / `On Duty` ruxsat etiladi.
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton.secondary(
                label: l10n.dutyStatusOffDuty,
                drivingMode: true,
                onPressed: () => controller.changeStatus(DutyStatusValue.off),
              ),
            ),
            const SizedBox(width: Spacing.s10),
            Expanded(
              child: AppButton.primary(
                label: l10n.dutyStatusOnDuty,
                drivingMode: true,
                onPressed: () => controller.changeStatus(DutyStatusValue.on),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Flexible(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: context.text.body14.copyWith(color: context.colors.textSecondary),
        ),
      ),
      const SizedBox(width: Spacing.s10),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: context.text.body13.copyWith(color: context.colors.textPrimary),
        ),
      ),
    ],
  );
}
