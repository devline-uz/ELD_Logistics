/// `M-43 Notifications` (telefon) va `T-29` (planshet paneli).
///
/// Figma: `1156-7135` (light) / `2665-35068` (dark), bo'sh holat `1156-7244`.
/// Bitta [NotificationsController] — ikkala profil uchun (M7).
///
/// Holatlar: yuklanish (skeleton) · bo'sh · xato · to'la.
/// Oflayn: `load()` yiqilsa lokal kesh ko'rsatiladi, xato faqat kesh bo'sh
/// bo'lganda to'liq ekranga chiqadi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/time/time_providers.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_deeplink.dart';
import '../../domain/push_gateway.dart';
import '../controllers/notifications_controller.dart';
import '../notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({this.onOpenDeepLink, super.key});

  /// M145: element bosilganda ochiladigan marshrut. `null` bo'lsa navigatsiya
  /// qilinmaydi (golden/test rejimi) — `core/router` integratsiyasi buni
  /// `context.go` bilan to'ldiradi.
  final void Function(String route)? onOpenDeepLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final NotificationsUiState ui = ref.watch(notificationsControllerProvider);
    final AsyncValue<List<AppNotification>> items = ref.watch(notificationsProvider);
    final List<AppNotification> list = items.value ?? const <AppNotification>[];
    final PushPermissionStatus? permission = ref.watch(pushPermissionProvider).value;
    final bool blocked = permission == PushPermissionStatus.denied;

    ref.listen<NotificationsUiState>(notificationsControllerProvider, (
      NotificationsUiState? previous,
      NotificationsUiState next,
    ) {
      if (next.allReadDone && previous?.allReadDone != true) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(l10n.notifAllReadDone)));
        ref.read(notificationsControllerProvider.notifier).acknowledgeAllRead();
      }
    });

    final Widget body = _NotificationsBody(
      ui: ui,
      items: list,
      loadingCache: items.isLoading,
      onOpenDeepLink: onOpenDeepLink,
    );

    return AdaptiveScaffold(
      // Figma `1156:7135` app bar: orqaga tugmasi + sarlavha, standart amal
      // guruhi (bell/mail/refresh) yo'q — o'rniga `Mark all read` (dizaynda
      // yo'q, TZ §15 talab qiladi).
      appBar: AppBarPrimary(
        title: l10n.notifTitle,
        leading: const AppBackButton(),
        showDefaultActions: false,
        actions: <Widget>[
          if (list.any((AppNotification n) => !n.read))
            AppButton.text(
              label: l10n.notifMarkAllRead,
              onPressed: ref.read(notificationsControllerProvider.notifier).markAllRead,
            ),
        ],
      ),
      banners: <Widget>[
        // M143: OS darajasida o'chirilgan bo'lsa — banner + `Enable`.
        if (blocked)
          BannerStrip(
            message: l10n.notifDisabledBanner,
            tone: BannerTone.warning,
            actionLabel: l10n.notifEnableAction,
            onAction: () => ref.read(pushGatewayProvider).openSystemSettings(),
          ),
      ],
      phone: (BuildContext context) => body,
      tablet: (BuildContext context) => Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: body),
      ),
    );
  }
}

class _NotificationsBody extends ConsumerWidget {
  const _NotificationsBody({
    required this.ui,
    required this.items,
    required this.loadingCache,
    required this.onOpenDeepLink,
  });

  final NotificationsUiState ui;
  final List<AppNotification> items;
  final bool loadingCache;
  final void Function(String route)? onOpenDeepLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final NotificationsController controller = ref.read(notificationsControllerProvider.notifier);

    if (items.isEmpty && (ui.loading || loadingCache)) {
      return const LoadingSkeleton(itemCount: 6);
    }
    if (items.isEmpty && ui.error != null) {
      final ApiError error = ui.error!;
      return ErrorState(
        message: localizedApiError(l10n, error),
        retryLabel: l10n.commonRetry,
        onRetry: controller.refresh,
      );
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.notifications_none,
        title: l10n.notifEmptyTitle,
        message: l10n.notifEmptyMessage,
      );
    }

    final DateTime now = ref.watch(timeSourceProvider).now();
    final List<NotificationDaySection> sections = groupNotificationsByDay(items, dayOf: _dayOf);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
        children: <Widget>[
          for (final NotificationDaySection section in sections) ...<Widget>[
            _DayHeader(day: section.day),
            for (final AppNotification item in section.items)
              NotificationTile(
                notification: item,
                timeLabel: relativeNotificationTime(l10n, item.createdAt, now),
                onTap: () => _open(ref, item),
              ),
          ],
          if (ui.hasMore)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.s10),
              child: ui.loadingMore
                  ? const Center(child: _Spinner())
                  : AppButton.text(label: l10n.notifLoadMore, onPressed: controller.loadMore),
            ),
        ],
      ),
    );
  }

  Future<void> _open(WidgetRef ref, AppNotification item) async {
    await ref.read(notificationsControllerProvider.notifier).markRead(item.id);
    final String? route = notificationDeepLink(item.type, entityId: item.entityId);
    if (route != null) {
      onOpenDeepLink?.call(route);
    }
  }

  /// TODO(M42): Home Terminal TZ ulangach kun chegarasi `TimeSource` dan.
  static DateTime _dayOf(DateTime utc) {
    final DateTime local = utc.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

/// M91: <24 soat — nisbiy, keyin `MMM d, hh:mm a`.
String relativeNotificationTime(AppLocalizations l10n, DateTime createdAt, DateTime now) {
  final NotificationTimeLabel label = notificationTimeLabel(createdAt, now);
  return switch (label.kind) {
    NotificationTimeKind.justNow => l10n.notifRelativeNow,
    NotificationTimeKind.minutes => l10n.notifRelativeMinutes(label.value),
    NotificationTimeKind.hours => l10n.notifRelativeHours(label.value),
    NotificationTimeKind.absolute => AppFormats.notificationDate.format(createdAt.toLocal()),
  };
}

/// Guruh sarlavhasi. Figma da `May 28, 2025`, **M91** uni yagona
/// `EEE, MMM d` formatiga keltiradi (§11.0.7 jadvali, #B-19).
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.s10, bottom: Spacing.base),
    child: Text(
      AppFormats.listHeaderOf(day),
      style: context.text.body11.copyWith(color: context.colors.textPrimary),
    ),
  );
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: Spacing.s20,
    height: Spacing.s20,
    child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
  );
}
