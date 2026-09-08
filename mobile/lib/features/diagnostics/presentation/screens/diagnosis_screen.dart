/// **M-46 Diagnosis of device** (`/profile/diagnosis`) — Figma `1131:965`
/// (light) / `2665:28907` (dark), tz-mobile 1468 · 965–996 (§10.5).
///
/// Uch qator (dizayndagi kabi): `ELD coordinates`, `GPS coordinates`,
/// `Network quality`. Dizaynda modal, marshrut registrida to'liq ekran —
/// registr kanonik, shuning uchun ekran sifatida chiziladi va `AppBarPrimary`
/// bilan yopiladi.
///
/// Qo'shimcha: **M77** aktiv `P/E/T/L/R/S/O` kodlari ro'yxati (dizaynda yo'q,
/// TZ §10.6 talab qiladi — haydovchi qaysi kod yonganini ko'rishi shart).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_codes.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../eld_device/presentation/eld_labels.dart';
import '../../domain/diagnostics_models.dart';
import '../controllers/diagnostics_controller.dart';

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    appBar: AppBarPrimary(title: context.l10n.diagnosisTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const DiagnosisBody(),
    tablet: (BuildContext context) => const DiagnosisBody(),
  );
}

/// T-23 (planshet modali) shu tanani ishlatadi (M7).
class DiagnosisBody extends ConsumerWidget {
  const DiagnosisBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DeviceDiagnostics data = ref.watch(deviceDiagnosticsProvider);
    final List<EldFault> faults = ref.watch(eldActiveFaultsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        SettingsCard(
          children: <Widget>[
            _Row(
              label: l10n.diagnosisEldCoordinates,
              value: _stateLabel(l10n, data.eldCoordinates),
              tone: _stateTone(data.eldCoordinates),
            ),
            _Row(
              label: l10n.diagnosisGpsCoordinates,
              value: _stateLabel(l10n, data.gpsCoordinates),
              tone: _stateTone(data.gpsCoordinates),
            ),
            _Row(
              label: l10n.diagnosisNetworkQuality,
              value: _networkLabel(l10n, data.network),
              tone: _networkTone(data.network),
            ),
          ],
        ),
        const SizedBox(height: Spacing.cardGap),
        SettingsCard(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.s5),
              child: Text(
                l10n.diagnosisActiveFaults,
                style: context.text.body11.copyWith(color: context.colors.textPrimary),
              ),
            ),
            if (faults.isEmpty)
              Text(
                l10n.diagnosisNoFaults,
                style: context.text.body15.copyWith(color: context.colors.textSecondary),
              )
            else
              for (final EldFault fault in faults)
                SettingsRow(
                  // Kod harfi o'ngdagi badge'da — sarlavhada takrorlanmaydi.
                  label: eldFaultLabel(l10n, fault.code),
                  helper: eldFaultHint(l10n, fault),
                  showChevron: false,
                  trailing: StatusBadge(
                    label: fault.code.letter,
                    tone: fault.isMalfunction ? StatusTone.error : StatusTone.warning,
                    dense: true,
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

String _stateLabel(AppLocalizations l10n, DiagnosticState state) =>
    state == DiagnosticState.working ? l10n.diagnosisWorking : l10n.diagnosisNotWorking;

StatusTone _stateTone(DiagnosticState state) =>
    state == DiagnosticState.working ? StatusTone.success : StatusTone.error;

String _networkLabel(AppLocalizations l10n, NetworkQuality quality) => switch (quality) {
  NetworkQuality.good => l10n.diagnosisNetworkGood,
  NetworkQuality.fair => l10n.diagnosisNetworkFair,
  NetworkQuality.poor => l10n.diagnosisNetworkPoor,
  NetworkQuality.offline => l10n.diagnosisNetworkOffline,
};

StatusTone _networkTone(NetworkQuality quality) => switch (quality) {
  NetworkQuality.good => StatusTone.success,
  NetworkQuality.fair => StatusTone.warning,
  NetworkQuality.poor || NetworkQuality.offline => StatusTone.error,
};

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.tone});

  final String label;
  final String value;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: label,
    showChevron: false,
    trailing: StatusBadge(label: value, tone: tone, dense: true),
  );
}
