/// `M-10 Drawer` (tz-mobile 1255–1260, Figma `2697:33817`).
///
/// **M95:** `Maintenance` bandi yo'q (M67).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../duty_status/domain/duty_status_models.dart';

/// Drawer bandini bosganda chaqiriladigan amal.
enum HomeDrawerAction {
  inspectionReport,
  switchCoDriver,
  permissions,
  checkNetwork,
  diagnosis,
  appUpdates,
  feedback,
  customerSupport,
  userManual,
  leaveTruck,
  logout,
  termsOfUse,
  privacyPolicy,
}

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({
    required this.driver,
    required this.onAction,
    this.permissionsWarning = false,
    super.key,
  });

  final DriverContext driver;
  final ValueChanged<HomeDrawerAction> onAction;

  /// `Permissions (!)` — ruxsat berilmagan bo'lsa qizil nuqta.
  final bool permissionsWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final AppUiSettings settings = ref.watch(appUiSettingsProvider);
    final AppUiSettingsNotifier ui = ref.read(appUiSettingsProvider.notifier);

    // M-10 (Figma `1202:9259`/`2697:33817`): panel ekran kengligining ~66%
    // ini egallaydi (qolgan qismda scrim orqali home ko'rinadi).
    final double width = MediaQuery.sizeOf(context).width * 0.66;

    return Drawer(
      width: width,
      backgroundColor: c.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _DrawerLogo(),
            _Header(driver: driver),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
                children: <Widget>[
                  // Figma'da mavjud, TZ-mobile 1255 da tilga olinmagan
                  // bandlar — qo'shildi, TZ bandlari o'chirilmadi (W-qoida).
                  _Item(
                    icon: Icons.fact_check_outlined,
                    label: l10n.drawerInspectionReport,
                    onTap: () => onAction(HomeDrawerAction.inspectionReport),
                  ),
                  _Item(
                    icon: Icons.swap_horiz,
                    label: l10n.drawerSwitchCoDriver,
                    onTap: () => onAction(HomeDrawerAction.switchCoDriver),
                  ),
                  _Item(
                    icon: Icons.verified_user_outlined,
                    label: l10n.drawerPermissions,
                    warning: permissionsWarning,
                    onTap: () => onAction(HomeDrawerAction.permissions),
                  ),
                  _Item(
                    icon: Icons.wifi_tethering,
                    label: l10n.drawerCheckNetwork,
                    onTap: () => onAction(HomeDrawerAction.checkNetwork),
                  ),
                  _Item(
                    icon: Icons.medical_services_outlined,
                    label: l10n.drawerDiagnosis,
                    onTap: () => onAction(HomeDrawerAction.diagnosis),
                  ),
                  _Item(
                    icon: Icons.system_update,
                    label: l10n.drawerAppUpdates,
                    onTap: () => onAction(HomeDrawerAction.appUpdates),
                  ),
                  SwitchListTile.adaptive(
                    value: settings.zoom == ZoomLevel.large,
                    secondary: Icon(Icons.zoom_in, color: c.icon),
                    title: Text(
                      l10n.drawerZoom,
                      style: context.text.body13.copyWith(color: c.textPrimary),
                    ),
                    onChanged: (bool _) => ui.toggleZoom(),
                  ),
                  SwitchListTile.adaptive(
                    value: settings.themeMode == ThemeMode.dark || c.isDark,
                    secondary: Icon(Icons.dark_mode_outlined, color: c.icon),
                    title: Text(
                      l10n.drawerDarkMode,
                      style: context.text.body13.copyWith(color: c.textPrimary),
                    ),
                    onChanged: (bool value) =>
                        ui.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  ),
                  _Item(
                    icon: Icons.rate_review_outlined,
                    label: l10n.drawerFeedback,
                    onTap: () => onAction(HomeDrawerAction.feedback),
                  ),
                  _Item(
                    icon: Icons.support_agent,
                    label: l10n.drawerCustomerSupport,
                    onTap: () => onAction(HomeDrawerAction.customerSupport),
                  ),
                  _Item(
                    icon: Icons.menu_book_outlined,
                    label: l10n.drawerUserManual,
                    onTap: () => onAction(HomeDrawerAction.userManual),
                  ),
                  _Item(
                    icon: Icons.directions_walk,
                    label: l10n.drawerLeaveTruck,
                    onTap: () => onAction(HomeDrawerAction.leaveTruck),
                  ),
                ],
              ),
            ),
            // Figma: `Logout` ro'yxatdan ajratilgan holda pastda turadi.
            _Item(
              icon: Icons.logout,
              label: l10n.drawerLogout,
              destructive: true,
              onTap: () => onAction(HomeDrawerAction.logout),
            ),
            // Figma (`1202:9259`): `Privacy Policy`/`Terms of Use` ro'yxat
            // ichidagi oddiy bandlar kabi (ikonka + to'liq matn, kesilmagan);
            // TZ 1258: joylashuvi Logout'dan pastda saqlanadi.
            _Item(
              icon: Icons.privacy_tip_outlined,
              label: l10n.drawerPrivacyPolicy,
              onTap: () => onAction(HomeDrawerAction.privacyPolicy),
            ),
            _Item(
              icon: Icons.description_outlined,
              label: l10n.drawerTermsOfUse,
              onTap: () => onAction(HomeDrawerAction.termsOfUse),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + Spacing.s10),
          ],
        ),
      ),
    );
  }
}

/// Figma `1202:9259`/`2697:33817`: markazlashgan ONEBOOK ELD logotipi
/// menyu sarlavhasida. `HomeBrandLockup` bilan bir xil rang sxemasi,
/// drawer uchun kattaroq shrift.
class _DrawerLogo extends StatelessWidget {
  const _DrawerLogo();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.s20, bottom: Spacing.s10),
      child: Center(
        child: Semantics(
          header: true,
          label: l10n.appTitle,
          child: ExcludeSemantics(
            child: RichText(
              text: TextSpan(
                style: context.text.body9.copyWith(color: c.textPrimary),
                children: <InlineSpan>[
                  TextSpan(
                    text: l10n.homeBrandOne,
                    style: TextStyle(color: c.primary),
                  ),
                  TextSpan(text: l10n.homeBrandRest),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.driver});

  final DriverContext driver;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String license = <String?>[
      driver.licenseNumber,
      driver.licenseState,
    ].whereType<String>().where((String value) => value.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.all(Spacing.s15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: Spacing.s25,
                backgroundColor: c.surfaceAlt,
                child: Icon(Icons.person_outline, color: c.textSecondary),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppFormats.orNa(driver.driverName),
                      style: context.text.body11.copyWith(color: c.textPrimary),
                    ),
                    Text(
                      AppFormats.orNa(driver.unitNumber),
                      style: context.text.body14.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s10),
          Text(
            AppFormats.orNa(driver.email),
            style: context.text.body14.copyWith(color: c.textSecondary),
          ),
          Text(
            AppFormats.orNa(driver.phone),
            style: context.text.body14.copyWith(color: c.textSecondary),
          ),
          Text(
            AppFormats.orNa(license),
            style: context.text.body14.copyWith(color: c.textSecondary),
          ),
          const Divider(height: Spacing.s20),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.warning = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool warning;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = destructive ? c.error : c.textPrimary;
    // Figma: qator balandligi ~69 px (standart ListTile'dan zichroq emas).
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
      minVerticalPadding: Spacing.s15,
      leading: Icon(icon, color: color),
      title: Text(label, style: context.text.body13.copyWith(color: color)),
      trailing: warning ? Icon(Icons.error, color: c.error, size: Spacing.s20) : null,
      onTap: onTap,
    );
  }
}
