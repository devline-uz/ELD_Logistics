/// `core/ui` komponentlarining golden testlari — har biri **×4**
/// (light/dark × phone/tablet). Jami 18 komponent + 2 token bloki.
///
/// Yangilash: `flutter test test_goldens --update-goldens`.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/dev/gallery_previews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(() => SkeletonConfig.animationsEnabled = false);
  tearDownAll(() => SkeletonConfig.animationsEnabled = true);

  // --- Tokenlar ---
  goldenMatrix('tokens_colors', builder: () => const ColorsPreview());
  goldenMatrix('tokens_typography', builder: () => const TypographyPreview());

  // --- 1. AppBarPrimary ---
  goldenMatrix(
    'app_bar_primary',
    padding: EdgeInsets.zero,
    builder: () => SizedBox(
      // App bar `PreferredSizeWidget` — cheklangan balandlik talab qiladi.
      height: kAppBarHeight + Strokes.thin,
      child: AppBarPrimary(
        title: 'OneBook ELD',
        onLeadingPressed: () {},
        actions: const <Widget>[
          SyncIndicator(status: SyncStatus.idle),
          SyncIndicator(status: SyncStatus.error),
        ],
      ),
    ),
  );

  // --- 2. AppButton ×3 ---
  goldenMatrix(
    'app_button',
    builder: () => Column(
      children: <Widget>[
        AppButton.primary(label: 'Primary', onPressed: () {}),
        const SizedBox(height: Spacing.s10),
        AppButton.secondary(label: 'Secondary', onPressed: () {}),
        const SizedBox(height: Spacing.s10),
        AppButton.primary(label: 'Destructive', destructive: true, onPressed: () {}),
        const SizedBox(height: Spacing.s10),
        const AppButton.primary(label: 'Disabled'),
        const SizedBox(height: Spacing.s10),
        AppButton.text(label: 'Text button', onPressed: () {}),
        const SizedBox(height: Spacing.s10),
        AppButton.primary(label: 'Driving mode', drivingMode: true, onPressed: () {}),
      ],
    ),
  );

  // --- 3. AppTextField ---
  goldenMatrix(
    'app_text_field',
    builder: () => const Column(
      children: <Widget>[
        AppTextField(label: 'Truck number', hint: 'e.g. 1042'),
        SizedBox(height: Spacing.s15),
        AppTextField(label: 'Odometer', hint: '0', errorText: 'This field is required'),
        SizedBox(height: Spacing.s15),
        AppTextField(label: 'Disabled', hint: 'Read only', enabled: false),
      ],
    ),
  );

  // --- 4. AppChip ---
  goldenMatrix(
    'app_chip',
    builder: () => Wrap(
      spacing: Spacing.s10,
      runSpacing: Spacing.s10,
      children: <Widget>[
        AppChip(label: 'All', selected: true, onTap: () {}),
        AppChip(label: 'Pre-trip', onTap: () {}),
        AppChip(label: 'Post-trip', count: 4, onTap: () {}),
      ],
    ),
  );

  // --- 5. StatusBadge ---
  goldenMatrix(
    'status_badge',
    builder: () => const Wrap(
      spacing: Spacing.s10,
      runSpacing: Spacing.s10,
      children: <Widget>[
        StatusBadge(label: 'Certified', tone: StatusTone.success),
        StatusBadge(label: 'Not certified', tone: StatusTone.warning),
        StatusBadge(label: 'Violation', tone: StatusTone.error),
        StatusBadge(label: 'Draft', tone: StatusTone.neutral),
        StatusBadge(label: 'Active driver', tone: StatusTone.accent),
      ],
    ),
  );

  // --- 6. HosLinearIndicator (telefon) ---
  goldenMatrix('hos_linear_indicator', builder: () => const HosLinearPreview());

  // --- 7. HosRingIndicator (planshet) ---
  goldenMatrix('hos_ring_indicator', builder: () => const HosRingPreview());

  // --- 8. DutyGrid24h ---
  goldenMatrix(
    'duty_grid_24h',
    padding: const EdgeInsets.all(Spacing.s5),
    builder: () => const DutyGridPreview(),
  );

  // --- 9. DateStrip8Day ---
  goldenMatrix(
    'date_strip_8day',
    padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
    builder: () =>
        DateStripPreview(selected: DateTime.utc(2025, 5, 18), onSelected: (DateTime _) {}),
  );

  // --- 10. EmptyState ---
  goldenMatrix(
    'empty_state',
    builder: () => EmptyState(
      title: 'No DVIR Found',
      message: 'There is no data to show you right now.',
      actionLabel: 'Add DVIR',
      onAction: () {},
    ),
  );

  // --- 11. ErrorState ---
  goldenMatrix(
    'error_state',
    builder: () => ErrorState(
      title: 'Could not load logs',
      message: 'No internet connection. Your work is saved and will sync later.',
      retryLabel: 'Retry',
      onRetry: () {},
    ),
  );

  // --- 12. LoadingSkeleton ---
  goldenMatrix(
    'loading_skeleton',
    builder: () =>
        const SizedBox(height: 420, child: LoadingSkeleton(itemCount: 3, animate: false)),
  );

  // --- 13. AppBottomSheet (telefon) ---
  goldenMatrix(
    'app_bottom_sheet',
    padding: EdgeInsets.zero,
    devices: <GoldenDevice>[GoldenDevice.phone],
    builder: () => AppBottomSheet(
      title: 'Change Status',
      child: Column(
        children: <Widget>[
          AppButton.secondary(label: 'Off Duty', onPressed: () {}),
          const SizedBox(height: Spacing.s10),
          AppButton.secondary(label: 'Sleeper Berth', onPressed: () {}),
          const SizedBox(height: Spacing.s10),
          AppButton.secondary(label: 'On Duty', onPressed: () {}),
        ],
      ),
    ),
  );

  // --- 14. TabletModal (planshet) ---
  goldenMatrix(
    'tablet_modal',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    builder: () => TabletModal(
      title: 'Add DVIR',
      cancelLabel: 'Cancel',
      actionLabel: 'Save',
      onAction: () {},
      child: const AppTextField(label: 'Notes', hint: 'Describe the defect'),
    ),
  );

  // --- 15. ConfirmDialog ---
  goldenMatrix(
    'confirm_dialog',
    builder: () => const ConfirmDialog(
      title: 'Are you absolutely sure?',
      message: 'This log entry will be permanently removed.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Confirm',
      destructive: true,
    ),
  );

  // --- 16. SignaturePad ---
  goldenMatrix(
    'signature_pad',
    builder: () =>
        SignaturePad(clearLabel: 'Clear', saveLabel: 'Save', hint: 'Sign here', onSaved: (_) {}),
  );

  // --- 17. SyncIndicator (aylanish golden'da to'xtatilgan) ---
  goldenMatrix(
    'sync_indicator',
    pumpBeforeTest: pumpOnce,
    builder: () => const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SyncIndicator(status: SyncStatus.idle),
        SyncIndicator(status: SyncStatus.syncing),
        SyncIndicator(status: SyncStatus.error),
        SyncIndicator(status: SyncStatus.offline, pendingCount: 3),
      ],
    ),
  );

  // --- 18. BannerStrip ---
  goldenMatrix(
    'banner_strip',
    padding: EdgeInsets.zero,
    builder: () => Column(
      children: <Widget>[
        const BannerStrip(message: 'Offline — 3 records queued', tone: BannerTone.offline),
        const SizedBox(height: Spacing.s5),
        const BannerStrip(message: '2 days are not certified', tone: BannerTone.warning),
        const SizedBox(height: Spacing.s5),
        const BannerStrip(message: 'Violation: 11-hour driving limit', tone: BannerTone.violation),
        const SizedBox(height: Spacing.s5),
        BannerStrip(
          message: 'ELD disconnected',
          tone: BannerTone.eld,
          actionLabel: 'Reconnect',
          onAction: () {},
        ),
        const SizedBox(height: Spacing.s5),
        const BannerStrip(message: 'Co-driver: J. Smith', tone: BannerTone.info),
      ],
    ),
  );

  // --- M85: textScaler 1.3 da layout buzilmasligi ---
  goldenMatrix(
    'text_scale_max',
    textScale: kMaxTextScale,
    devices: <GoldenDevice>[GoldenDevice.phone],
    builder: () => Column(
      children: <Widget>[
        AppButton.primary(label: 'Certify this log', onPressed: () {}),
        const SizedBox(height: Spacing.s10),
        const StatusBadge(label: 'Not certified', tone: StatusTone.warning),
        const SizedBox(height: Spacing.s10),
        const HosLinearPreview(),
      ],
    ),
  );
}
