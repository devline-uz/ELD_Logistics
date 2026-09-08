/// **M-19 ELD device connect/scan** (`/eld`) — 🎨 dizaynda yo'q, tz-mobile
/// 930–964 (§10.3) va §21.6 dan quriladi.
///
/// Ikki holat:
/// * **ulangan** — handshake kartasi (firmware, serial, VIN, RTC, odometer,
///   engine hours) + VIN mosligi ogohlantirishi + M72 bufer hisoboti;
/// * **ulanmagan** — `Scan` (20 s), topilgan qurilmalar ro'yxati (RSSI,
///   `< −90 dBm` da `Weak signal`), `Connect`.
///
/// Ruxsatlar yetishmasa avval **M-17** dialogi chiqadi (M70).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_buffer_importer.dart';
import '../../../../core/eld/eld_models.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/eld/eld_session.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/eld_connect_controller.dart';
import '../eld_labels.dart';
import '../widgets/eld_not_connected_dialog.dart';
import '../widgets/eld_status_banner.dart';

class EldConnectScreen extends ConsumerWidget {
  const EldConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    // §21.6 (Figma yo'q): sub-ekran naqshi — faqat orqaga tugmasi + sarlavha.
    appBar: AppBarPrimary(
      title: context.l10n.eldConnectTitle,
      leading: const AppBackButton(),
      showDefaultActions: false,
    ),
    backgroundColor: context.colors.bg,
    banners: const <Widget>[EldStatusBanner()],
    phone: (BuildContext context) => const EldConnectBody(),
    tablet: (BuildContext context) => const EldConnectBody(),
  );
}

class EldConnectBody extends ConsumerWidget {
  const EldConnectBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final EldConnectUiState ui = ref.watch(eldConnectControllerProvider);
    final EldConnectController controller = ref.read(eldConnectControllerProvider.notifier);
    final EldSessionState session = ref.watch(eldSessionProvider).value ?? const EldSessionState();

    Future<void> startScan() async {
      if (!await ensureEldPermissions(context, ref)) {
        return;
      }
      await controller.scan();
    }

    Future<void> connect(String id) async {
      if (!await ensureEldPermissions(context, ref)) {
        return;
      }
      await controller.connect(id);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        if (session.handshake != null) ...<Widget>[
          _HandshakeCard(session: session, lastImport: ui.lastImport),
          const SizedBox(height: Spacing.cardGap),
          AppButton.secondary(
            label: l10n.eldDisconnectAction,
            onPressed: () => controller.disconnect(),
          ),
          const SizedBox(height: Spacing.s10),
          AppButton.text(
            label: l10n.eldForgetAction,
            onPressed: () => controller.disconnect(forget: true),
          ),
        ] else ...<Widget>[
          if (session.reconnectAttempt > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.s10),
              child: Text(
                l10n.eldReconnectingIn(session.reconnectAttempt),
                style: context.text.body17.copyWith(color: context.colors.textSecondary),
              ),
            ),
          if (ui.failure != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.s10),
              child: Text(
                eldFailureLabel(l10n, ui.failure!),
                style: context.text.body17.copyWith(color: context.colors.error),
              ),
            ),
          AppButton.primary(
            label: ui.devices.isEmpty && !ui.scanning
                ? l10n.eldScanAction
                : l10n.eldScanAgainAction,
            busy: ui.scanning,
            onPressed: ui.busy ? null : startScan,
          ),
          const SizedBox(height: Spacing.cardGap),
          if (ui.scanning && ui.devices.isEmpty)
            const SkeletonBox(width: double.infinity, height: 120)
          else if (ui.devices.isEmpty)
            EmptyState(title: l10n.eldScanEmptyTitle, message: l10n.eldScanEmptyMessage)
          else
            _DeviceList(
              devices: ui.devices,
              connectingId: ui.connectingId,
              onConnect: ui.busy ? null : connect,
            ),
        ],
      ],
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.devices, required this.connectingId, required this.onConnect});

  final List<EldDeviceRef> devices;
  final String? connectingId;
  final Future<void> Function(String id)? onConnect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SettingsCard(
      children: <Widget>[
        _SectionTitle(title: l10n.eldSectionAvailable),
        for (final EldDeviceRef device in devices)
          SettingsRow(
            label: device.name.isEmpty ? device.id : device.name,
            // RSSI `< −90 dBm` — tz-mobile §10.3 `[MAY]` ogohlantirishi.
            helper: device.isWeakSignal
                ? l10n.eldWeakSignal
                : (device.rssi == null ? null : l10n.eldSignalDbm(device.rssi!)),
            enabled: connectingId == null,
            showChevron: false,
            onTap: onConnect == null ? null : () => onConnect!(device.id),
            trailing: connectingId == device.id
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : StatusBadge(label: l10n.eldConnectAction, tone: StatusTone.accent, dense: true),
          ),
      ],
    );
  }
}

class _HandshakeCard extends StatelessWidget {
  const _HandshakeCard({required this.session, required this.lastImport});

  final EldSessionState session;
  final EldBufferImportResult? lastImport;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final EldHandshake handshake = session.handshake!;
    final int? odometerM = handshake.odometerM;
    final double? engineHours = handshake.engineHours;

    return SettingsCard(
      children: <Widget>[
        _SectionTitle(title: l10n.eldSectionDevice),
        _Field(label: l10n.eldFieldFirmware, value: handshake.firmware),
        _Field(label: l10n.eldFieldSerial, value: AppFormats.orNa(handshake.serial)),
        _Field(label: l10n.eldFieldVin, value: AppFormats.orNa(handshake.vin)),
        // M71: shu RTC `TimeSource` ga berilgan.
        _Field(label: l10n.eldFieldRtc, value: AppFormats.fullDateTime(handshake.rtcUtc)),
        _Field(
          label: l10n.eldFieldOdometer,
          value: odometerM == null
              ? AppFormats.orNa(null)
              : l10n.eldOdometerKm((odometerM / 1000).round().toString()),
        ),
        _Field(
          label: l10n.eldFieldEngineHours,
          value: engineHours == null
              ? AppFormats.orNa(null)
              : l10n.eldEngineHoursValue(engineHours.toStringAsFixed(1)),
        ),
        if (session.vinMatch == VinMatchResult.mismatch)
          _Note(text: l10n.eldVinMismatch, error: true)
        else if (session.vinMatch == VinMatchResult.unknown)
          _Note(text: l10n.eldVinUnknown, error: false),
        // M72: `imported` + `skipped` — takroriy o'qishda hammasi `skipped`.
        if (lastImport != null)
          _Note(
            text: l10n.eldBufferImported(lastImport!.imported, lastImport!.skipped),
            error: false,
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: label,
    showChevron: false,
    // Qiymat uzun bo'lishi mumkin (VIN, sana) — kengligi cheklanadi, aks holda
    // `SettingsRow` ning `Row` i chetdan chiqib ketadi.
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: context.text.body15.copyWith(color: context.colors.textSecondary),
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.error});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.s5),
    child: Text(
      text,
      style: context.text.body17.copyWith(
        color: error ? context.colors.error : context.colors.textSecondary,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.s5),
    child: Text(title, style: context.text.body11.copyWith(color: context.colors.textPrimary)),
  );
}
