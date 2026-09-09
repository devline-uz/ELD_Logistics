/// **M-44 Profile** (`/profile`) — Figma `1119:445` (light) / `2665:29782` (dark).
///
/// Bandlar (tz-mobile §11.8): `Settings` · `Check network` · `Zoom` · `Dark mode`
/// · `Feedback` · `Customer support` · `User Manual` · `My devices` ·
/// `Change PIN` · huquqiy havolalar · `Logout`.
/// **M112 [MUST]** `Maintenance` bandi yo'q (M67) — Figma dagi band ataylab
/// tashlab ketilgan.
///
/// Telefon va planshet bitta `ProfileController` ni ulashadi (M7).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/app_config_info.dart';
import '../../domain/driver_profile.dart';
import '../../domain/m11_permissions.dart';
import '../../profile_routes.dart';
import '../controllers/app_config_controller.dart';
import '../controllers/profile_controller.dart';
import '../navigation.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DriverProfile> state = ref.watch(profileControllerProvider);
    final AppLocalizations l10n = context.l10n;

    return AdaptiveScaffold(
      // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
      maxContentWidth: ContentWidth.wide,
      appBar: AppBarPrimary(title: l10n.profileTitle),
      backgroundColor: context.colors.bg,
      phone: (BuildContext context) => _Body(state: state, tablet: false),
      tablet: (BuildContext context) => _Body(state: state, tablet: true),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state, required this.tablet});

  final AsyncValue<DriverProfile> state;
  final bool tablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return asyncView<DriverProfile>(
      state,
      loading: const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 4),
      ),
      error: (Object error) => ErrorState(
        message: error is ApiError ? localizedApiError(l10n, error) : l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
      ),
      data: (DriverProfile profile) => RefreshIndicator(
        onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
          children: <Widget>[
            ProfileHeader(profile: profile),
            const SizedBox(height: Spacing.s25),
            if (tablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Expanded(child: _PreferencesCard()),
                  const SizedBox(width: Spacing.s20),
                  Expanded(child: _HelpCard(profile: profile)),
                ],
              )
            else ...<Widget>[
              const _PreferencesCard(),
              const SizedBox(height: Spacing.cardGap),
              _HelpCard(profile: profile),
            ],
            const SizedBox(height: Spacing.cardGap),
            const _LegalCard(),
            const SizedBox(height: Spacing.cardGap),
            const _LogoutCard(),
          ],
        ),
      ),
    );
  }
}

/// Figma dagi birinchi karta: `Settings` · `Check network` · `Zoom` · `Dark mode`.
class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppUiSettings ui = ref.watch(appUiSettingsProvider);
    final AppUiSettingsNotifier notifier = ref.read(appUiSettingsProvider.notifier);
    final bool isDark = context.colors.isDark;

    return SettingsCard(
      children: <Widget>[
        SettingsRow(label: l10n.profileSettings, onTap: () => context.push(ProfileRoute.settings)),
        SettingsRow(
          label: l10n.profileCheckNetwork,
          onTap: () => pushOrNotify(context, ProfileRoute.checkNetwork),
        ),
        // Figma da `Zoom` bandi ostida tushuntirish matni yo'q — tavsif faqat
        // skrinriderga (`semanticLabel`) beriladi.
        SettingsRow(
          label: l10n.profileZoom,
          showChevron: false,
          // #B-18: `AppSwitch` (yashil `switchTrackOn` track + to'liq oq thumb);
          // Material `Switch` ishlatilmaydi.
          trailing: AppSwitch(
            value: ui.zoom == ZoomLevel.large,
            semanticLabel: l10n.profileZoomSemantics,
            onChanged: (bool value) => notifier.setZoom(value ? ZoomLevel.large : ZoomLevel.normal),
          ),
        ),
        SettingsRow(
          label: l10n.profileDarkMode,
          showChevron: false,
          trailing: AppSwitch(
            value: isDark,
            semanticLabel: l10n.profileDarkMode,
            onChanged: (bool value) =>
                notifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
        ),
      ],
    );
  }
}

/// Ikkinchi karta: `Feedback` · `Customer support` · `User Manual` ·
/// `My devices` · `Change PIN`.
class _HelpCard extends ConsumerWidget {
  const _HelpCard({required this.profile});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    // `user_manual_url` mavjudligini bilish uchun o'qiladi (M11-4 gacha faqat
    // bandning yoqilgan/o'chirilgan holatiga ta'sir qiladi).
    final AppConfigInfo? config = ref.watch(appConfigControllerProvider).value;

    return SettingsCard(
      children: <Widget>[
        // RBAC: backend `permissions` ro'yxatida huquq bo'lmasa band ko'rinmaydi.
        if (profile.has(kPermFeedbackCreate))
          SettingsRow(
            label: l10n.profileFeedback,
            onTap: () => context.push(ProfileRoute.feedback),
          ),
        if (profile.has(kPermSupportRead))
          SettingsRow(
            label: l10n.profileCustomerSupport,
            onTap: () => context.push(ProfileRoute.support),
          ),
        SettingsRow(
          label: l10n.profileUserManual,
          // TODO(M11-4): tashqi havolani ochish uchun `url_launcher` kerak
          // (pubspec — arxitektor hududi). Hozircha havola yo'qligi bildiriladi.
          enabled: config?.userManualUrl != null || config == null,
          onTap: () => _notifyUnavailable(context),
        ),
        SettingsRow(
          label: l10n.profileMyDevices,
          onTap: () => pushOrNotify(context, ProfileRoute.sessions),
        ),
        SettingsRow(
          label: l10n.profileChangePin,
          onTap: () => pushOrNotify(context, ProfileRoute.changePin),
        ),
      ],
    );
  }

  void _notifyUnavailable(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.profileUnavailableLink)));
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SettingsCard(
      children: <Widget>[
        SettingsRow(
          label: l10n.legalPrivacyTitle,
          onTap: () => context.push(ProfileRoute.legalPrivacy),
        ),
        SettingsRow(
          label: l10n.legalTermsTitle,
          onTap: () => context.push(ProfileRoute.legalTerms),
        ),
      ],
    );
  }
}

class _LogoutCard extends ConsumerWidget {
  const _LogoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    return SettingsCard(
      children: <Widget>[
        SettingsRow(
          label: l10n.profileLogout,
          destructive: true,
          showChevron: false,
          onTap: () => _confirm(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = context.l10n;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool ok = await showConfirmDialog(
      context: context,
      title: l10n.profileLogoutConfirmTitle,
      message: l10n.profileLogoutConfirmMessage,
      cancelLabel: l10n.commonCancel,
      confirmLabel: l10n.profileLogout,
      destructive: true,
    );
    if (!ok) {
      return;
    }
    try {
      await ref.read(profileControllerProvider.notifier).logout();
    } on ApiError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(localizedApiError(l10n, error))));
    }
  }
}
