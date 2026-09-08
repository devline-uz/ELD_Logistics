/// **M143/M144** — bildirishnoma turkumlari ro'yxati.
///
/// `Settings` (M-45) shu widget'ni o'z ichiga oladi. `compliance` va
/// `foreground_service` kanallari **qulflangan**: toggle o'chirilgan holatda
/// ko'rinadi + «Required for compliance» tooltip'i.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_channels.dart';
import '../controllers/notification_preferences_controller.dart';

class NotificationChannelToggles extends ConsumerWidget {
  const NotificationChannelToggles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final NotificationPreferences prefs =
        ref.watch(notificationPreferencesProvider).value ?? const NotificationPreferences();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.notifChannelsTitle,
          style: context.text.body11.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: Spacing.s10),
        for (final PushChannel channel in PushChannel.values)
          _ChannelRow(
            channel: channel,
            enabled: prefs.isEnabled(channel),
            locked: isChannelLocked(channel),
            onChanged: (bool value) =>
                ref.read(notificationPreferencesProvider.notifier).toggle(channel, enabled: value),
          ),
      ],
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.channel,
    required this.enabled,
    required this.locked,
    required this.onChanged,
  });

  final PushChannel channel;
  final bool enabled;
  final bool locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Semantics(
      toggled: enabled,
      enabled: !locked,
      child: Container(
        constraints: BoxConstraints(minHeight: touchTarget(context)),
        padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: c.stroke, width: Strokes.thin),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    channelTitle(l10n, channel),
                    style: context.text.body12.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: Spacing.base),
                  Text(
                    locked ? l10n.notifRequiredForCompliance : channelBody(l10n, channel),
                    style: context.text.body15.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.s10),
            Tooltip(
              message: locked ? l10n.notifRequiredForCompliance : '',
              child: Switch(
                value: enabled,
                onChanged: locked ? null : onChanged,
                activeTrackColor: c.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// M144 kanal nomlari.
String channelTitle(AppLocalizations l10n, PushChannel channel) => switch (channel) {
  PushChannel.compliance => l10n.notifChannelCompliance,
  PushChannel.logs => l10n.notifChannelLogs,
  PushChannel.messages => l10n.notifChannelMessages,
  PushChannel.general => l10n.notifChannelGeneral,
};

String channelBody(AppLocalizations l10n, PushChannel channel) => switch (channel) {
  PushChannel.compliance => l10n.notifChannelComplianceBody,
  PushChannel.logs => l10n.notifChannelLogsBody,
  PushChannel.messages => l10n.notifChannelMessagesBody,
  PushChannel.general => l10n.notifChannelGeneralBody,
};
