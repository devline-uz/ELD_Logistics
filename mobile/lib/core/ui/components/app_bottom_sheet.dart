/// `AppBottomSheet` (telefon) va `TabletModal` (planshet) — tz-mobile §11.0.4.
///
/// **Qoida:** telefonda modal pastdan chiqadi, planshetda markazda.
/// Chaqiruvchi to'g'ridan-to'g'ri `showModalBottomSheet` ishlatmaydi —
/// [showAdaptiveModal] profil bo'yicha to'g'ri variantni tanlaydi (M7).
///
/// Radius: `Radii.sheet` = 24 (Figma da o'lchangan; tz-mobile dagi 27.25
/// aslida soya blur radiusi — DIFF #D-01).
library;

import 'package:flutter/material.dart';

import '../../device/device_profile.dart';
import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Telefon uchun pastki varaq.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
    super.key,
  });

  /// Lokalizatsiya qilingan sarlavha (ixtiyoriy).
  final String? title;

  final Widget child;

  /// 4×32 dp drag handle.
  final bool showHandle;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      decoration: BoxDecoration(color: c.surface, borderRadius: Radii.sheetRadius),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (showHandle) ...<Widget>[
              const SizedBox(height: Spacing.s10),
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(color: c.strokeStrong, borderRadius: Radii.pillRadius),
                ),
              ),
            ],
            if (title != null) ...<Widget>[
              const SizedBox(height: Spacing.s15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.screenPaddingPhone),
                child: Text(
                  title!,
                  style: context.text.body8.copyWith(color: c.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Padding(
              padding:
                  padding ??
                  const EdgeInsets.fromLTRB(
                    Spacing.screenPaddingPhone,
                    Spacing.s20,
                    Spacing.screenPaddingPhone,
                    Spacing.s20,
                  ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Planshet uchun markazlashgan modal.
///
/// Tepa qatori: `Cancel · <sarlavha> · <amal>` (M122).
class TabletModal extends StatelessWidget {
  const TabletModal({
    required this.title,
    required this.child,
    this.cancelLabel,
    this.onCancel,
    this.actionLabel,
    this.onAction,
    this.actionEnabled = true,
    this.width = 560,
    super.key,
  });

  /// Lokalizatsiya qilingan sarlavha.
  final String title;

  final Widget child;

  /// Chapdagi bekor qilish matni (lokalizatsiyalangan).
  final String? cancelLabel;
  final VoidCallback? onCancel;

  /// O'ngdagi asosiy amal matni (lokalizatsiyalangan).
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;

  final double width;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: Radii.modalRadius,
          boxShadow: context.shadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(Spacing.s20),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 96,
                    child: cancelLabel == null
                        ? null
                        : TextButton(
                            onPressed: onCancel ?? () => Navigator.of(context).pop(),
                            child: Text(
                              cancelLabel!,
                              style: context.text.body12.copyWith(color: c.textSecondary),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: context.text.body8.copyWith(color: c.textPrimary),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: actionLabel == null
                        ? null
                        : TextButton(
                            onPressed: actionEnabled ? onAction : null,
                            child: Text(
                              actionLabel!,
                              style: context.text.body12.copyWith(
                                color: actionEnabled ? c.primary : c.textDisabled,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Divider(height: Strokes.thin, thickness: Strokes.thin, color: c.stroke),
            // #B-133: `TabletModal` `Scaffold`siz `showDialog` ichida ochiladi —
            // tanada `InkWell`/`ListTile` bo'lsa `Material` ajdodi bo'lmasdi.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.s20),
                child: Material(type: MaterialType.transparency, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profilga mos modal ochadi: telefonda pastki varaq, planshetda markaziy modal.
Future<T?> showAdaptiveModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  if (DeviceProfile.of(context).isTablet) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: context.colors.scrim,
      builder: builder,
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    useSafeArea: true,
    backgroundColor: context.colors.transparent,
    barrierColor: context.colors.scrim,
    builder: builder,
  );
}

/// Modal/varaq tanasi uchun yagona o'ram (#B-133).
///
/// Ikki muammoni birdan yopadi:
///  * `Material` ajdodi — `InkWell`/`ListTile` bo'lgan tana `showDialog`
///    ichida `No Material widget found` bermasin;
///  * bog'langan balandlik — `ListView`/`Column` modal ichida cheksiz
///    balandlik ololmaydi.
///
/// Ilgari bu yordamchi 7 ta modal faylida `_pane()` sifatida takrorlanardi.
Widget modalPane(Widget child, double height) => Material(
  type: MaterialType.transparency,
  child: SizedBox(height: height, child: child),
);
