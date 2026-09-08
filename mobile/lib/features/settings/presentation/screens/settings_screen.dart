/// **M-45 Settings** (`/profile/settings`) — Figma `1131:392` (light) /
/// `2665:27939` (dark).
///
/// TZ §11.8: `Diagnosis of device ›` · `App updates` (joriy versiya,
/// `latest_version`, `Update`). Bularga qo'shimcha ravishda **M143**
/// bildirishnoma sozlamalari va til bo'limi shu ekranda turadi.
///
/// Telefon va planshet bitta kontrollerni ulashadi (M7) — farq faqat ustunlar
/// joylashuvida.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/app_version.dart';
import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../profile/domain/app_config_info.dart';
import '../../../profile/presentation/controllers/app_config_controller.dart';
import '../../../profile/presentation/navigation.dart';
import '../../../profile/profile_routes.dart';
import '../../domain/notification_prefs.dart';
import '../controllers/notification_prefs_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.wide,
    appBar: AppBarPrimary(title: context.l10n.settingsTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const _Body(tablet: false),
    tablet: (BuildContext context) => const _Body(tablet: true),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.tablet});

  final bool tablet;

  @override
  Widget build(BuildContext context) {
    const List<Widget> left = <Widget>[_GeneralCard()];
    const List<Widget> right = <Widget>[_NotificationsCard(), _LanguageCard()];

    if (!tablet) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
        children: const <Widget>[
          _GeneralCard(),
          SizedBox(height: Spacing.cardGap),
          _NotificationsCard(),
          SizedBox(height: Spacing.cardGap),
          _LanguageCard(),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: Column(children: _spaced(left))),
            const SizedBox(width: Spacing.s20),
            Expanded(child: Column(children: _spaced(right))),
          ],
        ),
      ],
    );
  }

  List<Widget> _spaced(List<Widget> items) => <Widget>[
    for (int i = 0; i < items.length; i++) ...<Widget>[
      if (i > 0) const SizedBox(height: Spacing.cardGap),
      items[i],
    ],
  ];
}

/// Figma `1131:392`: **bitta** karta, ikki band — `Diagnosis of device ›` va
/// `App updates`. Versiya qatorlari va `Update` tugmasi shu kartaning ichida
/// (`App updates` uchun alohida marshrut TZ §11.1 registrida yo'q).
class _GeneralCard extends ConsumerWidget {
  const _GeneralCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppVersion installed = ref.watch(resolvedAppVersionProvider);
    final AsyncValue<AppConfigInfo> config = ref.watch(appConfigControllerProvider);

    return SettingsCard(
      children: <Widget>[
        SettingsRow(
          label: l10n.settingsDiagnosis,
          onTap: () => pushOrNotify(context, ProfileRoute.diagnosis),
        ),
        SettingsRow(label: l10n.settingsAppUpdates, showChevron: false),
        SettingsRow(label: l10n.settingsCurrentVersion(installed.version), showChevron: false),
        asyncView<AppConfigInfo>(
          config,
          loading: const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.s5),
            child: SkeletonBox(width: 180, height: 20),
          ),
          error: (Object error) => ErrorState(
            message: error is ApiError ? localizedApiError(l10n, error) : l10n.errUnknown,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.read(appConfigControllerProvider.notifier).refresh(),
          ),
          data: (AppConfigInfo info) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SettingsRow(
                label: l10n.settingsLatestVersion(AppFormats.orNa(info.latestVersion)),
                showChevron: false,
              ),
              const SizedBox(height: Spacing.s10),
              if (info.isNewerThan(installed.version))
                AppButton.primary(
                  label: l10n.settingsUpdateAction,
                  // TODO(M11-4): store havolasini ochish uchun `url_launcher`
                  // kerak (pubspec — arxitektor hududi).
                  onPressed: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.profileUnavailableLink))),
                )
              else
                Text(
                  l10n.settingsUpToDate,
                  style: context.text.body16.copyWith(color: context.colors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// **M143** — `hos_*` / `eld_*` toggle'lari o'chirilgan holatda ko'rsatiladi.
class _NotificationsCard extends ConsumerWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final NotificationPrefs prefs = ref.watch(notificationPrefsProvider);
    final NotificationPrefsController controller = ref.read(notificationPrefsProvider.notifier);

    return SettingsCard(
      children: <Widget>[
        _SectionTitle(title: l10n.settingsNotifications),
        for (final AlertType type in AlertType.values)
          SettingsRow(
            label: alertTypeLabel(l10n, type),
            showChevron: false,
            helper: type.isLocked ? l10n.settingsNotificationsLocked : null,
            trailing: SettingsToggle(
              value: prefs.isEnabled(type),
              semanticLabel: alertTypeLabel(l10n, type),
              onChanged: type.isLocked
                  ? null
                  : (bool value) => controller.setEnabled(type, enabled: value),
            ),
          ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SettingsCard(
      children: <Widget>[
        _SectionTitle(title: l10n.settingsLanguage),
        SettingsRow(
          label: l10n.settingsLanguageEnglish,
          helper: l10n.settingsLanguageOnlyEnglish,
          showChevron: false,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.s5),
    child: Text(title, style: context.text.body11.copyWith(color: context.colors.textPrimary)),
  );
}

/// Push turi → lokalizatsiya qilingan nom.
String alertTypeLabel(AppLocalizations l10n, AlertType type) => switch (type) {
  AlertType.hosWarning => l10n.settingsAlertHosWarning,
  AlertType.hosViolation => l10n.settingsAlertHosViolation,
  AlertType.eldDisconnected => l10n.settingsAlertEldDisconnected,
  AlertType.eldMalfunction => l10n.settingsAlertEldMalfunction,
  AlertType.uncertifiedLog => l10n.settingsAlertUncertifiedLog,
  AlertType.logEditResolved => l10n.settingsAlertLogEditResolved,
  AlertType.dvirDefects => l10n.settingsAlertDvirDefects,
  AlertType.chatMessage => l10n.settingsAlertChatMessage,
};
