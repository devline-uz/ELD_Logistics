/// `M-43` ro'yxat elementi (Figma `1156-7135`, dark `2665-35068`).
///
/// Figma o'lchamlari: sarlavha 16/20 Medium, tana 14/20 Regular
/// (`textSecondary`), vaqt 12/18 (`textSecondary`), ostida 1 px ajratgich.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.timeLabel,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;

  /// M91: <24 soat nisbiy, keyin `MMM d, hh:mm a` (chaqiruvchi hisoblaydi —
  /// widget `DateTime.now()` ni bilmaydi).
  final String timeLabel;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color accent = _severityColor(c, severityOf(notification.type));

    return Semantics(
      button: true,
      selected: !notification.read,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: touchTarget(context)),
          padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: c.stroke, width: Strokes.thin),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(alertIcon(notification.type), size: Spacing.s20, color: accent),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!notification.read) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: Spacing.s5),
                            child: _UnreadDot(color: c.primary),
                          ),
                          const SizedBox(width: Spacing.s5),
                        ],
                        Expanded(
                          child: Text(
                            AppFormats.orNa(notification.title),
                            style: context.text.body12.copyWith(color: c.textPrimary),
                          ),
                        ),
                        const SizedBox(width: Spacing.s10),
                        Text(
                          timeLabel,
                          style: context.text.body16.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...<Widget>[
                      const SizedBox(height: Spacing.s5),
                      Text(
                        notification.body,
                        style: context.text.body15.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _severityColor(AppColors c, AlertSeverity severity) => switch (severity) {
    AlertSeverity.critical => c.error,
    AlertSeverity.warning => c.warning,
    AlertSeverity.info => c.textSecondary,
  };
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: Spacing.base,
    height: Spacing.base,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// `alert_type` → ikonka (`swagger.json` enum'idagi 16 qiymat + noma'lum).
IconData alertIcon(AlertType? type) => switch (type) {
  AlertType.hosWarning => Icons.timer_outlined,
  AlertType.hosViolation => Icons.gpp_bad_outlined,
  AlertType.routeAssigned => Icons.alt_route,
  AlertType.routeCompleted => Icons.task_alt,
  AlertType.dvirDefects => Icons.build_outlined,
  AlertType.dvirCritical => Icons.report_gmailerrorred_outlined,
  AlertType.logEditRequest => Icons.edit_note,
  AlertType.logEditResolved => Icons.check_circle_outline,
  AlertType.uncertifiedLog => Icons.assignment_late_outlined,
  AlertType.unidentifiedDriving => Icons.person_search_outlined,
  AlertType.eldDisconnected => Icons.bluetooth_disabled,
  AlertType.eldMalfunction => Icons.warning_amber_outlined,
  AlertType.maintenanceUpcoming => Icons.schedule,
  AlertType.maintenanceOverdue => Icons.error_outline,
  AlertType.chatMessage => Icons.chat_bubble_outline,
  AlertType.subscriptionExpiring => Icons.card_membership_outlined,
  null => Icons.notifications_none,
};

/// `alert_type` → lokalizatsiya qilingan tur nomi (semantics va filtrlar uchun).
String alertTypeLabel(AppLocalizations l10n, AlertType? type) => switch (type) {
  AlertType.hosWarning => l10n.notifTypeHosWarning,
  AlertType.hosViolation => l10n.notifTypeHosViolation,
  AlertType.routeAssigned => l10n.notifTypeRouteAssigned,
  AlertType.routeCompleted => l10n.notifTypeRouteCompleted,
  AlertType.dvirDefects => l10n.notifTypeDvirDefects,
  AlertType.dvirCritical => l10n.notifTypeDvirCritical,
  AlertType.logEditRequest => l10n.notifTypeLogEditRequest,
  AlertType.logEditResolved => l10n.notifTypeLogEditResolved,
  AlertType.uncertifiedLog => l10n.notifTypeUncertifiedLog,
  AlertType.unidentifiedDriving => l10n.notifTypeUnidentifiedDriving,
  AlertType.eldDisconnected => l10n.notifTypeEldDisconnected,
  AlertType.eldMalfunction => l10n.notifTypeEldMalfunction,
  AlertType.maintenanceUpcoming => l10n.notifTypeMaintenanceUpcoming,
  AlertType.maintenanceOverdue => l10n.notifTypeMaintenanceOverdue,
  AlertType.chatMessage => l10n.notifTypeChatMessage,
  AlertType.subscriptionExpiring => l10n.notifTypeSubscriptionExpiring,
  null => l10n.notifTypeUnknown,
};
