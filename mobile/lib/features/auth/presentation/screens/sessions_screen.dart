/// `M-58 Sessions (my devices)` (`/profile/sessions`) 🎨 — Figma referensi
/// yo'q (tz-mobile 1524, §4.6).
///
/// `GET /auth/sessions`: qurilma turi, IP (serverda qisqartirilgan), oxirgi
/// faollik, `current` badge; `DELETE /auth/sessions/{id}` bilan chiqarish.
///
/// 4 holat: `yuklanish` (skeleton) · `bo'sh` · `xato` (`ErrorState` + Retry) ·
/// `to'la`. Planshetda tana `ContentWidth.single` bilan markazlashtiriladi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/driver_session.dart';
import '../controllers/sessions_controller.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<SessionsState> async = ref.watch(sessionsControllerProvider);
    final SessionsController controller = ref.read(sessionsControllerProvider.notifier);

    final Widget body = asyncView<SessionsState>(
      async,
      loading: const LoadingSkeleton(itemCount: 3),
      error: (Object error) => ErrorState(
        message: error is ApiError ? localizedApiError(l10n, error) : l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: controller.refresh,
      ),
      data: (SessionsState state) => SessionsList(state: state, onRevoke: controller.revoke),
    );

    return AdaptiveScaffold(
      appBar: AppBarPrimary(title: l10n.authSessionsTitle, leading: const AppBackButton()),
      maxContentWidth: ContentWidth.single,
      phone: (BuildContext c) => body,
      tablet: (BuildContext c) => body,
    );
  }
}

/// Ro'yxat tanasi — widget/golden testlarida to'g'ridan-to'g'ri chiziladi.
class SessionsList extends StatelessWidget {
  const SessionsList({required this.state, required this.onRevoke, super.key});

  final SessionsState state;
  final ValueChanged<String> onRevoke;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    if (state.loading) {
      return const LoadingSkeleton(itemCount: 3);
    }
    if (state.error != null) {
      return ErrorState(
        message: localizedApiError(l10n, state.error!),
        retryLabel: l10n.commonRetry,
      );
    }
    if (state.isEmpty) {
      return EmptyState(
        title: l10n.authSessionsEmptyTitle,
        message: l10n.authSessionsEmptyMessage,
        icon: Icons.devices_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
      children: <Widget>[
        Text(
          l10n.authSessionsSubtitle,
          style: context.text.body15.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: Spacing.s15),
        for (final DriverSession session in state.sessions)
          SessionTile(
            session: session,
            busy: state.revoking == session.id,
            onRevoke: () => onRevoke(session.id),
          ),
      ],
    );
  }
}

class SessionTile extends StatelessWidget {
  const SessionTile({required this.session, required this.onRevoke, this.busy = false, super.key});

  final DriverSession session;
  final VoidCallback onRevoke;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.s10),
      padding: const EdgeInsets.all(Spacing.s15),
      decoration: BoxDecoration(color: c.surface, borderRadius: Radii.cardRadius),
      child: Row(
        children: <Widget>[
          Icon(_icon, size: Spacing.s30, color: c.textSecondary),
          const SizedBox(width: Spacing.s15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      _deviceLabel(l10n),
                      style: context.text.body11.copyWith(color: c.textPrimary),
                    ),
                    if (session.current) ...<Widget>[
                      const SizedBox(width: Spacing.s10),
                      StatusBadge(
                        label: l10n.authSessionsCurrent,
                        tone: StatusTone.success,
                        dense: true,
                      ),
                    ],
                  ],
                ),
                Text(
                  l10n.authSessionsLastSeen(session.lastSeenAt ?? DateTime.utc(2000)),
                  style: context.text.body16.copyWith(color: c.textSecondary),
                ),
                Text(
                  l10n.authSessionsIpLabel(AppFormats.orNa(session.ip)),
                  style: context.text.body16.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          if (session.revocable)
            AppButton.text(
              label: l10n.authSessionsRevoke,
              expand: false,
              busy: busy,
              onPressed: busy ? null : () => _confirm(context),
            ),
        ],
      ),
    );
  }

  IconData get _icon => switch (session.deviceType) {
    SessionDeviceType.web => Icons.computer_outlined,
    SessionDeviceType.phone => Icons.smartphone_outlined,
    SessionDeviceType.tablet => Icons.tablet_outlined,
  };

  String _deviceLabel(AppLocalizations l10n) => switch (session.deviceType) {
    SessionDeviceType.web => l10n.authSessionsDeviceWeb,
    SessionDeviceType.phone => l10n.authSessionsDevicePhone,
    SessionDeviceType.tablet => l10n.authSessionsDeviceTablet,
  };

  Future<void> _confirm(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    final bool confirmed = await showConfirmDialog(
      context: context,
      title: l10n.authSessionsRevokeTitle,
      message: l10n.authSessionsRevokeBody,
      confirmLabel: l10n.authSessionsRevoke,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (confirmed) {
      onRevoke();
    }
  }
}
