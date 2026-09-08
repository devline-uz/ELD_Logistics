/// **M-47 Check network** (`/profile/network`) — Figma `1122:319` (light) /
/// `2665:29068` (dark), tz-mobile 1469–1470 · 965–977 (§10.5).
///
/// Yarim doira o'lchagich (`0…100 mbps`) + `Check Network` tugmasi.
///
/// **M75 [MUST]** tashqi speedtest xizmati ishlatilmaydi.
/// **❓M76** `v1` da test fayli endpoint'i yo'q — MVP da `GET /app/config`
/// javob vaqti asosidagi **taxminiy** qiymat (`approx.` yorlig'i bilan).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/diagnostics_models.dart';
import '../controllers/diagnostics_controller.dart';
import '../widgets/network_gauge.dart';

class CheckNetworkScreen extends ConsumerWidget {
  const CheckNetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    appBar: AppBarPrimary(title: context.l10n.checkNetworkTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const CheckNetworkBody(),
    tablet: (BuildContext context) => const CheckNetworkBody(),
  );
}

/// T-21 (planshet modali) shu tanani ishlatadi (M7).
class CheckNetworkBody extends ConsumerWidget {
  const CheckNetworkBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<NetworkMeasurement?> async = ref.watch(networkCheckControllerProvider);
    final NetworkMeasurement? value = async.value;
    final bool running = async.isLoading;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s30),
      children: <Widget>[
        Center(
          child: NetworkGauge(value: value?.mbps, approximate: value?.approximate ?? true),
        ),
        const SizedBox(height: Spacing.s25),
        // #B-63: Figma `1122:319` da tugma to'q neytral (`#1C1E24`), brend
        // qizil emas — `AppButton.neutral`.
        AppButton.neutral(
          label: l10n.checkNetworkTitle,
          busy: running,
          onPressed: running ? null : ref.read(networkCheckControllerProvider.notifier).run,
        ),
        const SizedBox(height: Spacing.s20),
        Center(
          child: Text(
            _statusText(l10n, async, value),
            textAlign: TextAlign.center,
            style: context.text.body15.copyWith(
              color: async.hasError ? context.colors.error : context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: Spacing.s10),
        Center(
          child: Text(
            // M75 tushuntirishi.
            l10n.checkNetworkNote,
            textAlign: TextAlign.center,
            style: context.text.body17.copyWith(color: context.colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

String _statusText(
  AppLocalizations l10n,
  AsyncValue<NetworkMeasurement?> async,
  NetworkMeasurement? value,
) {
  if (async.isLoading) {
    return l10n.checkNetworkRunning;
  }
  if (async.hasError) {
    return l10n.checkNetworkFailed;
  }
  if (value == null) {
    return l10n.checkNetworkIdle;
  }
  return l10n.checkNetworkLatency(value.roundTrip.inMilliseconds);
}
