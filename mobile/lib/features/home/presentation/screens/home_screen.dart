/// `M-09 Home` (`/home`, Figma `2177:12192` — B tartib, M87).
///
/// **M88:** scroll'siz ko'rinadigan qism — ELD banneri, sana/unit, joriy
/// status + hisoblagich, 4 ta HOS indikatori, tezkor amallar. Trip Details,
/// Certify va log bloki scroll ostida.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/auth_routes.dart';
import '../../../auth/data/session_manager.dart';
import '../../../auth/domain/auth_models.dart';
import '../../../auth/domain/session_state.dart';
import '../../../auth/presentation/widgets/co_driver_switch_modal.dart';
import '../../../auth/presentation/widgets/leave_truck_dialog.dart';
import '../../../drive_mode/drive_mode_routes.dart';
import '../../../drive_mode/presentation/controllers/drive_mode_controller.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/duty_status_routes.dart';
import '../../domain/home_models.dart';
import '../../home_routes.dart';
import '../controllers/home_controller.dart';
import '../widgets/active_driver_banner.dart';
import '../widgets/edit_documents_sheet.dart';
import '../widgets/home_brand_lockup.dart';
import '../widgets/home_cards.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_log_cards.dart';
import 'tablet/home_tablet_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final HomeState state = ref.watch(homeControllerProvider);
    final HomeController controller = ref.read(homeControllerProvider.notifier);
    final DualSessionState session = ref.watch(sessionManagerProvider);
    final DateTime now =
        ref.watch(secondTickProvider).value ?? state.duty.since ?? DateTime.utc(2000);

    // M57: auto-DR aniqlanganda haydash rejimi ≤1 s ichida ochiladi.
    // `DriveModeController` shu yerda tirik bo'lgani uchun harakat oqimi Home
    // ochiq turganda ham kuzatiladi (M56).
    ref.listen<DriveModeState>(driveModeControllerProvider, (
      DriveModeState? previous,
      DriveModeState next,
    ) {
      if (previous != null && !previous.driving && next.driving) {
        context.push(DriveModeRoute.drive);
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.colors.bg,
      drawer: HomeDrawer(
        driver: state.driver,
        onAction: (HomeDrawerAction action) => _onDrawerAction(context, ref, action),
      ),
      // Figma `2177:12192`: chapda hamburger + logotip lockup, balandlik 54,
      // o'ngda standart `bell · mail · refresh` guruhi (#B-01…#B-04).
      appBar: AppBarPrimary(
        title: l10n.appTitle,
        titleWidget: const HomeBrandLockup(),
        height: kAppBarHeightHome,
        leadingLabel: l10n.homeMenu,
        onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onNotifications: () => context.push(HomeLinks.notifications),
        onMessages: () => context.go(AppRoute.chat),
        onRefresh: controller.refresh,
        actions: <Widget>[
          // §11.0.6: tema almashtirish ikonkasi **faqat planshet** app bar'ida
          // (telefonda `Profile › Dark mode` toggle'i).
          if (DeviceProfile.of(context).isTablet) ...<Widget>[
            AppBarAction(
              icon: Icons.brightness_6_outlined,
              label: l10n.homeThemeToggle,
              onPressed: () =>
                  ref.read(appUiSettingsProvider.notifier).toggleTheme(Theme.brightnessOf(context)),
            ),
            const SizedBox(width: Spacing.s15),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // M10: faol haydovchi doim ko'rinadi (ikki sessiya aralashmasin).
            if (!session.isSignedOut)
              ActiveDriverBanner(
                session: session,
                onSwitch: session.hasCoDriver ? () => _openCoDriverSwitch(context, ref) : null,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenPaddingH(context)),
                child: AdaptiveView(
                  phone: (BuildContext c) => _PhoneView(
                    banners: _banners(context, state),
                    state: state,
                    controller: controller,
                    now: now,
                    onCoDriver: () => _openCoDriverSwitch(context, ref),
                    onLeaveTruck: () => showLeaveTruckDialog(context, ref),
                  ),
                  tablet: (BuildContext c) => HomeTabletView(
                    banners: _banners(context, state),
                    state: state,
                    controller: controller,
                    now: now,
                    onChangeStatus: (DutyStatusValue _) => context.push(DutyStatusRoute.change),
                    onEditDocuments: () => showEditDocumentsSheet(context, state.trip),
                    actions: HomeTabletActions(
                      onInspection: () => context.push(HomeLinks.inspection),
                      onCoDriver: () => _openCoDriverSwitch(context, ref),
                      onLeaveTruck: () => showLeaveTruckDialog(context, ref),
                      onCertify: () => context.push(HomeLinks.certify),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _banners(BuildContext context, HomeState state) {
    final AppLocalizations l10n = context.l10n;
    return <Widget>[
      switch (state.eld) {
        HomeEldBanner.connected => BannerStrip(
          message: l10n.homeEldConnected,
          tone: BannerTone.info,
        ),
        HomeEldBanner.notConnected => BannerStrip(
          message: l10n.homeEldNotConnected,
          tone: BannerTone.eld,
        ),
        // M77: malfunction banneri yopilmaydi.
        HomeEldBanner.malfunction => BannerStrip(
          message: l10n.homeEldMalfunction(state.malfunctionCode ?? kEmptyValue),
          tone: BannerTone.violation,
        ),
      },
      if (state.offline)
        BannerStrip(message: l10n.homeOfflineQueued(state.queuedRecords), tone: BannerTone.offline),
    ];
  }

  /// `M-20 → M-04 PIN → M-21` oqimi (§3.3).
  ///
  /// Slotlar **faqat** PIN tasdiqlangandan keyin almashadi, shuning uchun
  /// modal `true` qaytarsa `/pin?action=switch_driver` ga o'tiladi; PIN ekrani
  /// muvaffaqiyatda `M-21` ni ochadi.
  static Future<void> _openCoDriverSwitch(BuildContext context, WidgetRef ref) async {
    final bool? proceed = await showCoDriverSwitchModal(context);
    if (!context.mounted) {
      return;
    }
    if (proceed ?? false) {
      unawaited(
        context.push<void>(
          '${AppRoute.pin}?${AuthRoute.actionParam}=${PinAction.switchDriver.wire}',
        ),
      );
      return;
    }
    // `Sign in co-driver` — ikkinchi slot uchun login formasi.
    if (proceed == false && ref.read(sessionManagerProvider).passive.isEmpty) {
      unawaited(context.push<void>(AppRoute.login));
    }
  }

  static void _onDrawerAction(BuildContext context, WidgetRef ref, HomeDrawerAction action) {
    Navigator.of(context).pop();
    if (action == HomeDrawerAction.logout) {
      unawaited(showLogoutDialog(context, ref));
      return;
    }
    final String target = switch (action) {
      HomeDrawerAction.inspectionReport => HomeLinks.inspection,
      HomeDrawerAction.switchCoDriver => HomeLinks.coDriver,
      HomeDrawerAction.leaveTruck => HomeLinks.leaveTruck,
      HomeDrawerAction.permissions => HomeLinks.permissions,
      HomeDrawerAction.checkNetwork => HomeLinks.checkNetwork,
      HomeDrawerAction.diagnosis => HomeLinks.diagnosis,
      HomeDrawerAction.feedback => HomeLinks.feedback,
      HomeDrawerAction.customerSupport => HomeLinks.support,
      HomeDrawerAction.termsOfUse => HomeLinks.terms,
      HomeDrawerAction.privacyPolicy => HomeLinks.privacy,
      HomeDrawerAction.userManual => HomeLinks.userManual,
      HomeDrawerAction.appUpdates => HomeLinks.appUpdates,
      HomeDrawerAction.logout => HomeLinks.logout,
    };
    context.push(target);
  }
}

class _PhoneView extends StatelessWidget {
  const _PhoneView({
    required this.banners,
    required this.state,
    required this.controller,
    required this.now,
    this.onCoDriver,
    this.onLeaveTruck,
  });

  final List<Widget> banners;
  final HomeState state;
  final HomeController controller;
  final DateTime now;
  final VoidCallback? onCoDriver;
  final VoidCallback? onLeaveTruck;

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 4),
      );
    }
    if (!state.hasUnit) {
      return EmptyState(
        title: context.l10n.homeNoUnitTitle,
        message: context.l10n.homeNoUnitMessage,
        icon: Icons.local_shipping_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
        children: <Widget>[
          AppCardColumn(
            children: <Widget>[
              ...banners,
              ...homeSections(
                context,
                state,
                controller,
                now,
                onCoDriver: onCoDriver,
                onLeaveTruck: onLeaveTruck,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ikkala ko'rinish uchun umumiy bloklar (M7: mantiq takrorlanmaydi).
List<Widget> homeSections(
  BuildContext context,
  HomeState state,
  HomeController controller,
  DateTime now, {
  VoidCallback? onCoDriver,
  VoidCallback? onLeaveTruck,
}) {
  final AppLocalizations l10n = context.l10n;
  return <Widget>[
    HomeDateUnitCard(date: now, driver: state.driver),
    HomeStatusCard(
      status: state.duty.current,
      special: state.duty.special,
      elapsed: state.duty.since == null ? Duration.zero : now.difference(state.duty.since!),
      sleeperAvailable: state.duty.sleeperAvailable,
      onSelected: (DutyStatusValue value) => context.push(DutyStatusRoute.change),
      onSwap: onCoDriver,
    ),
    HomeHosCard(state: state),
    HomeQuickActions(
      onInspection: () => context.push(HomeLinks.inspection),
      onLogReport: () => context.go(AppRoute.logs),
      onCoDriver: onCoDriver ?? () {},
      onLeaveTruck: onLeaveTruck ?? () {},
    ),
    HomeTripCard(trip: state.trip, onEdit: () => showEditDocumentsSheet(context, state.trip)),
    HomeCertifyCard(days: state.certifyDays, onTap: () => context.push(HomeLinks.certify)),
    if (state.pendingEdits > 0)
      HomeAlertCard(
        label: l10n.homePendingEdits(state.pendingEdits),
        onTap: () => context.push(HomeLinks.pendingEdits),
      ),
    if (state.unidentified > 0)
      HomeAlertCard(
        label: l10n.homeUnidentifiedDriving(state.unidentified),
        onTap: () => context.push(HomeLinks.unidentified),
      ),
    HomeLogCard(state: state),
  ];
}
