/// `BannerStrip` — app bar ostidagi bir qatorli banner (tz-mobile §11.0.4/§11.0.5).
///
/// Figma parite (#B-24, #B-25): **to'ldirilgan quti** — `r8`, padding 12,
/// minimal balandlik 40. `eld` turi: `r12`, fon `#D70004`, oq matn.
/// Turlari: `offline` (kulrang `surfaceAlt`), `warning`
/// (sertifikatlanmagan kunlar), `violation` (`error`), `eld` (ELD uzilgan),
/// `info`. Matn **parametr** — masalan `Offline — 3 records queued`
/// (`app_en.arb` da plural bilan).
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Banner minimal balandligi — Figma 40 (#B-25).
const double kBannerHeight = 40;

enum BannerTone {
  /// Tarmoq yo'q — neytral kulrang.
  offline,

  /// Sertifikatlanmagan kunlar, ogohlantirish.
  warning,

  /// HOS buzilishi — `error`.
  violation,

  /// ELD qurilmasi uzilgan / malfunction.
  eld,

  /// Umumiy ma'lumot (co-driver, kiosk rejimi).
  info,
}

class BannerStrip extends StatelessWidget {
  const BannerStrip({
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.dismissLabel,
    super.key,
  });

  /// Lokalizatsiya qilingan matn.
  final String message;

  final BannerTone tone;

  /// O'ngdagi amal matni (lokalizatsiyalangan), masalan `Reconnect`.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Yopish tugmasi (ba'zi bannerlar yopilmaydi — `null` qoldiriladi).
  final VoidCallback? onDismiss;
  final String? dismissLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (Color bg, Color fg, IconData icon) = switch (tone) {
      BannerTone.offline => (c.surfaceAlt, c.textSecondary, Icons.cloud_off_outlined),
      BannerTone.warning => (c.warning, c.onPrimary, Icons.warning_amber_outlined),
      BannerTone.violation => (c.error, c.onPrimary, Icons.gpp_maybe_outlined),
      BannerTone.eld => (c.alert, c.onPrimary, Icons.bluetooth_disabled_outlined),
      BannerTone.info => (c.primaryLight, c.primary, Icons.info_outline),
    };
    final BorderRadius radius = tone == BannerTone.eld ? Radii.cardRadius : Radii.buttonRadius;

    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        constraints: const BoxConstraints(minHeight: kBannerHeight),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.s10 + Spacing.base / 2.5,
          vertical: Spacing.s10,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: Spacing.s15, color: fg),
            const SizedBox(width: Spacing.s5),
            Expanded(
              child: Text(
                message,
                style: context.text.body16.copyWith(color: fg),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            if (actionLabel != null && onAction != null)
              GestureDetector(
                onTap: onAction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.s5),
                  child: Text(
                    actionLabel!,
                    style: context.text.body16.copyWith(
                      color: fg,
                      decoration: TextDecoration.underline,
                      decorationColor: fg,
                    ),
                  ),
                ),
              ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Semantics(
                  button: true,
                  label: dismissLabel,
                  child: Icon(Icons.close, size: Spacing.s15, color: fg),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
