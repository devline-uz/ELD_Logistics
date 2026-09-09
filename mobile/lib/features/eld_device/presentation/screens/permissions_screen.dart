/// **M-18 Permissions** (`/permissions`) — Figma `1107:2310` (light) /
/// `2665:30606` (dark), tz-mobile §10.2 (906–929) va §17.7 (1927–1937).
///
/// Ikkita karta:
/// 1. **ruxsatlar** — `Location`, `Location always`, `Bluetooth`,
///    `Notifications` + `Allowed`/`Not allowed` badge;
/// 2. **tizim xizmatlari** — `Turn on GPS`, `Turn on bluetooth` + `On`/`Off`.
///
/// **M69:** rad etilgan ruxsat ilovani bloklamaydi — pastda tushuntirish va
/// `Allow all permissions` tugmasi turadi. «Don't ask again» holatida qator
/// tizim sozlamalarini ochadi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_permissions.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/permissions_controller.dart';
import '../eld_labels.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    // Figma `1107:2310` app bar: faqat orqaga tugmasi + sarlavha.
    appBar: AppBarPrimary(
      title: context.l10n.permissionsTitle,
      leading: const AppBackButton(),
      showDefaultActions: false,
    ),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const PermissionsBody(),
    tablet: (BuildContext context) => const PermissionsBody(),
  );
}

/// T-22 (planshet modali) ham shu tanani ishlatadi (M7).
class PermissionsBody extends ConsumerWidget {
  const PermissionsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<EldPermissionSnapshot> async = ref.watch(eldPermissionSnapshotProvider);

    // `AsyncValue.when` ishlatilmaydi: Riverpod 3 avtomatik retry `AsyncLoading`
    // (`retrying: true`) beradi va `when` uni **loading** deb ko'rsatadi —
    // `ErrorState` hech qachon chiqmaydi (`asyncView` doc'iga qara).
    return asyncView<EldPermissionSnapshot>(
      async,
      loading: const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: SkeletonBox(width: double.infinity, height: 240),
      ),
      error: (Object error) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.read(permissionsControllerProvider.notifier).refresh(),
      ),
      data: (EldPermissionSnapshot snapshot) => _Loaded(snapshot: snapshot),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.snapshot});

  final EldPermissionSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final PermissionsController controller = ref.read(permissionsControllerProvider.notifier);
    final PermissionsUiState ui = ref.watch(permissionsControllerProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        SettingsCard(
          children: <Widget>[
            for (final EldPermission permission in EldPermission.screenRows)
              _PermissionRow(
                permission: permission,
                status: snapshot.statusOf(permission),
                busy: ui.pending == permission,
                onTap: () =>
                    controller.requestOrOpenSettings(permission, snapshot.statusOf(permission)),
              ),
          ],
        ),
        const SizedBox(height: Spacing.cardGap),
        SettingsCard(
          children: <Widget>[
            SettingsRow(
              label: l10n.permissionTurnOnGps,
              leadingIcon: Icons.gps_fixed,
              trailing: _OnOffBadge(on: snapshot.locationServicesOn),
              onTap: controller.openLocationSettings,
            ),
            SettingsRow(
              label: l10n.permissionTurnOnBluetooth,
              leadingIcon: Icons.bluetooth,
              trailing: _OnOffBadge(on: snapshot.bluetoothOn),
              onTap: controller.openBluetoothSettings,
            ),
          ],
        ),
        if (snapshot.hasWarning) ...<Widget>[
          const SizedBox(height: Spacing.cardGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s5),
            child: Text(
              l10n.permissionDeniedHint,
              style: context.text.body17.copyWith(color: context.colors.textSecondary),
            ),
          ),
          const SizedBox(height: Spacing.s15),
          AppButton.primary(
            label: l10n.permissionAllowAll,
            busy: ui.runningFlow,
            onPressed: ui.busy ? null : controller.runOnboardingFlow,
          ),
        ],
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.permission,
    required this.status,
    required this.busy,
    required this.onTap,
  });

  final EldPermission permission;
  final EldPermissionStatus status;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SettingsRow(
      label: eldPermissionLabel(l10n, permission),
      leadingIcon: _iconOf(permission),
      // Risk R1: fon joylashuvi alohida tushuntirish bilan so'raladi.
      helper: permission == EldPermission.locationAlways ? l10n.permissionAlwaysHint : null,
      enabled: !busy,
      onTap: busy ? null : onTap,
      trailing: StatusBadge(
        label: status.needsSettings
            ? l10n.permissionOpenSettings
            : eldPermissionStatusLabel(l10n, status),
        tone: status.isAllowed ? StatusTone.success : StatusTone.error,
        dense: true,
      ),
    );
  }
}

/// Figma `1107:2310` dagi leading ikonkalar (#B-62).
///
/// Figma nomlari: `proicons:location`, `hugeicons:location-08`,
/// `proicons:bluetooth`, `iconamoon:notification-light` — eng yaqin Material
/// ekvivalentlari olinadi (ikonka to'plami loyihada Material).
IconData _iconOf(EldPermission permission) => switch (permission) {
  EldPermission.locationWhenInUse => Icons.location_on_outlined,
  EldPermission.locationAlways => Icons.my_location_outlined,
  EldPermission.bluetooth => Icons.bluetooth,
  EldPermission.notifications => Icons.notifications_none,
  EldPermission.batteryOptimization => Icons.battery_saver_outlined,
};

class _OnOffBadge extends StatelessWidget {
  const _OnOffBadge({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) => StatusBadge(
    label: on ? context.l10n.permissionOn : context.l10n.permissionOff,
    tone: on ? StatusTone.success : StatusTone.error,
    dense: true,
  );
}
