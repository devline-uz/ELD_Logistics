/// `ActiveDriverBanner` — **M10:** faol haydovchi **doim ko'rinadi**.
///
/// Tepa panelda ism + avatar, ikkinchi haydovchi kichikroq. Ikki sessiya
/// aralashib ketmasligi uchun fon `Primary #B7002C` (`context.colors.primary`).
///
/// Telefon va planshetda bir xil widget: planshetda balandroq (M8 teginish
/// maydoni ≥56) va `Switch` tugmasi matn bilan.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/domain/session_state.dart';

class ActiveDriverBanner extends StatelessWidget {
  const ActiveDriverBanner({required this.session, this.onSwitch, super.key});

  final DualSessionState session;

  /// `M-20` modalini ochadi; `null` bo'lsa tugma ko'rsatilmaydi (M11).
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final SessionSlotState active = session.active;
    final SessionSlotState co = session.passive;

    return Container(
      height: touchTarget(context),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s15),
      color: c.primary,
      child: Row(
        children: <Widget>[
          Icon(Icons.account_circle, size: Spacing.s25, color: c.onPrimary),
          const SizedBox(width: Spacing.s10),
          Flexible(
            child: Text(
              l10n.homeActiveDriverBanner(AppFormats.orNa(active.driverName)),
              style: context.text.body12.copyWith(color: c.onPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (co.isOccupied) ...<Widget>[
            const SizedBox(width: Spacing.s15),
            Flexible(
              child: Text(
                '${l10n.homeCoDriverLabel}: ${AppFormats.orNa(co.driverName)}',
                style: context.text.body16.copyWith(color: c.onPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          if (onSwitch != null)
            TextButton(
              onPressed: onSwitch,
              child: Text(
                l10n.homeSwitchDriver,
                style: context.text.body12.copyWith(color: c.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
