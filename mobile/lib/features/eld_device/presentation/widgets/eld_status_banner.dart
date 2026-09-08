/// ELD holat banneri (tz-mobile §10.1, M68, **M77**).
///
/// Ustuvorlik: **malfunction > diagnostic > ulanish holati**
/// ([EldSessionState.bannerState]).
///
/// **M77 [MUST]** malfunction banneri:
/// * matn — «ELD malfunction (\<kod\>) — keep paper logs»;
/// * rangi — Error;
/// * **dismiss tugmasi YO'Q** — faqat holat tiklanganda yo'qoladi.
///
/// `Connected` holatida banner **umuman chizilmaydi** (dizaynda Home'da
/// yashil chiziq faqat qisqa vaqt ko'rinadi; doimiy holat — sarlavhadagi
/// indikator).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_codes.dart';
import '../../../../core/eld/eld_models.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/eld/eld_session.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../eld_labels.dart';

/// `AdaptiveScaffold.banners` ga qo'yiladigan widget.
class EldStatusBanner extends ConsumerWidget {
  const EldStatusBanner({this.onAction, super.key});

  /// `Reconnect` bosilganda — odatda `/eld` ga o'tish.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EldSessionState? session = ref.watch(eldSessionProvider).value;
    if (session == null) {
      return const SizedBox.shrink();
    }
    return EldStatusBannerView(session: session, onAction: onAction);
  }
}

/// Sof ko'rinish — golden va widget testlarida to'g'ridan-to'g'ri ishlatiladi.
class EldStatusBannerView extends StatelessWidget {
  const EldStatusBannerView({required this.session, this.onAction, super.key});

  final EldSessionState session;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final EldConnectionState state = session.bannerState;

    if (state == EldConnectionState.connected) {
      return const SizedBox.shrink();
    }

    // M77: bir nechta malfunction bo'lsa birinchisi (kod tartibi P→O) ko'rsatiladi.
    final EldFault? malfunction = session.malfunctions.isEmpty ? null : session.malfunctions.first;
    final bool blocking = state == EldConnectionState.malfunction;

    return BannerStrip(
      message: eldConnectionLabel(l10n, state, code: malfunction?.code.letter),
      tone: state == EldConnectionState.diagnostic ? BannerTone.warning : BannerTone.eld,
      // M77: malfunction bannerida amal ham, dismiss ham yo'q.
      actionLabel: blocking || onAction == null ? null : l10n.eldBannerReconnect,
      onAction: blocking ? null : onAction,
    );
  }
}
