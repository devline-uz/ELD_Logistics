/// Android 13+ `POST_NOTIFICATIONS` (va iOS `requestAuthorization`) uchun
/// tushuntirish oynasi.
///
/// Ruxsat **so'rovdan oldin** sababi ko'rsatiladi (bir marta rad etilsa OS
/// qayta so'ramaydi). Manifest/`Info.plist` allaqachon sozlangan; bu yerda
/// faqat Dart tarafi.
///
/// Chaqiruvchi — bootstrap yoki `M-09 Home` (birinchi kirishdan keyin):
/// ```dart
/// await showNotificationPermissionSheet(context, ref);
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/push_gateway.dart';
import '../notification_providers.dart';

/// Ruxsat hali so'ralmagan bo'lsa tushuntirish ko'rsatadi va natijani
/// qaytaradi. Allaqachon berilgan/rad etilgan bo'lsa — oyna ochilmaydi.
Future<PushPermissionStatus> showNotificationPermissionSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final PushGateway gateway = ref.read(pushGatewayProvider);
  final PushPermissionStatus status = await gateway.permissionStatus();
  if (status != PushPermissionStatus.notDetermined || !context.mounted) {
    return status;
  }
  final bool? proceed = await showAdaptiveModal<bool>(
    context: context,
    builder: (BuildContext context) => AppBottomSheet(
      title: context.l10n.notifPermissionTitle,
      child: const NotificationPermissionBody(),
    ),
  );
  if (proceed != true) {
    return PushPermissionStatus.notDetermined;
  }
  return gateway.requestPermission();
}

/// Oyna tarkibi — golden/widget testda alohida ishlatiladi.
class NotificationPermissionBody extends StatelessWidget {
  const NotificationPermissionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.notifPermissionBody,
          style: context.text.body15.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: Spacing.s20),
        AppButton.primary(
          label: l10n.notifPermissionAllow,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: Spacing.s10),
        AppButton.text(
          label: l10n.notifPermissionNotNow,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
